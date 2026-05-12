import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import 'package:btg_funds_app/core/clock.dart';
import 'package:btg_funds_app/core/errors/exceptions.dart';
import 'package:btg_funds_app/core/errors/failure.dart';
import 'package:btg_funds_app/core/storage/atomic_write.dart';
import 'package:btg_funds_app/core/storage/storage_keys.dart';
import 'package:btg_funds_app/core/utils/formatters.dart';
import 'package:btg_funds_app/core/utils/validators.dart';
import 'package:btg_funds_app/features/funds/domain/usecases/get_fund_by_id_usecase.dart';
import 'package:btg_funds_app/features/subscriptions/data/models/subscription_model.dart';
import 'package:btg_funds_app/features/subscriptions/domain/entities/subscription.dart';
import 'package:btg_funds_app/features/subscriptions/domain/repositories/subscription_repository.dart';
import 'package:btg_funds_app/features/transactions/data/models/transaction_model.dart';
import 'package:btg_funds_app/features/transactions/domain/entities/transaction_type.dart';
import 'package:btg_funds_app/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:btg_funds_app/features/transactions/domain/usecases/add_transaction_usecase.dart';
import 'package:btg_funds_app/features/user/domain/entities/notification_channel.dart';
import 'package:btg_funds_app/features/user/domain/repositories/user_repository.dart';

/// Orquesta la suscripción a un fondo aplicando las validaciones del
/// SPEC_FUNCIONAL §5.1 y persistiendo balance + subscriptions +
/// transactions atómicamente vía [AtomicWrite].
///
/// **Signature recibe `String fundId` (no `Fund`)** porque la validación
/// "fondo existe" es regla de negocio y debe ejecutarse desde el use case
/// (no asumir validez por la UI). Desviación consciente del SKILL §4.
///
/// **Orden de validación optimizado vs. SPEC §5.1:** la validación pura
/// del monto (>0 y entero) se ejecuta justo después de resolver el fondo
/// y ANTES de las llamadas async a subscriptions/balance/user. El SPEC
/// la lista como paso 5; aquí queda como paso 2 para fallar rápido sin
/// gastar I/O. Los mensajes de error y la semántica de cada regla NO
/// cambian.
class SubscribeToFundUseCase {
  SubscribeToFundUseCase({
    required AddTransactionUseCase addTransactionUseCase,
    required AtomicWrite atomicWrite,
    required Clock clock,
    required GetFundByIdUseCase getFundByIdUseCase,
    required SubscriptionRepository subscriptionRepository,
    required TransactionRepository transactionRepository,
    required Uuid uuid,
    required UserRepository userRepository,
  })  : _addTransactionUseCase = addTransactionUseCase,
        _atomicWrite = atomicWrite,
        _clock = clock,
        _getFundByIdUseCase = getFundByIdUseCase,
        _subscriptionRepository = subscriptionRepository,
        _transactionRepository = transactionRepository,
        _uuid = uuid,
        _userRepository = userRepository;

  final AddTransactionUseCase _addTransactionUseCase;
  final AtomicWrite _atomicWrite;
  final Clock _clock;
  final GetFundByIdUseCase _getFundByIdUseCase;
  final SubscriptionRepository _subscriptionRepository;
  final TransactionRepository _transactionRepository;
  final Uuid _uuid;
  final UserRepository _userRepository;

  Future<Either<Failure, Subscription>> call({
    required String fundId,
    required double amount,
    required NotificationChannel channel,
  }) async {
    // 1. Fondo existe (async).
    final fundResult = await _getFundByIdUseCase(fundId);
    if (fundResult.isLeft()) {
      return Left(
        fundResult.swap().getOrElse(() => throw StateError('unreachable')),
      );
    }
    final fund = fundResult.getOrElse(() => throw StateError('unreachable'));

    // 2. Monto > 0 y entero (validación pura — falla rápido sin gastar
    //    más llamadas async).
    if (amount <= 0 || amount != amount.truncate()) {
      return const Left(
        BusinessFailure('Ingresa un monto válido en pesos colombianos.'),
      );
    }

    // 3. Usuario NO tiene suscripción activa en ese fondo (async).
    final subsResult = await _subscriptionRepository.getSubscriptions();
    if (subsResult.isLeft()) {
      return Left(
        subsResult.swap().getOrElse(() => throw StateError('unreachable')),
      );
    }
    final currentSubs =
        subsResult.getOrElse(() => throw StateError('unreachable'));

    if (currentSubs.any((s) => s.fundId == fund.id)) {
      return Left(
        BusinessFailure(
          'Ya tienes una participación activa en ${fund.name}. '
          'Cancélala primero.',
        ),
      );
    }

    // 4. Monto ≥ mínimo del fondo (validación pura sobre fund.minimumAmount).
    if (amount < fund.minimumAmount) {
      return Left(
        BusinessFailure(
          'El monto mínimo para ${fund.name} es ${fund.minimumAmount.toCop()}.',
        ),
      );
    }

    // 5. Monto ≤ saldo disponible (async).
    final balanceResult = await _userRepository.getBalance();
    if (balanceResult.isLeft()) {
      return Left(
        balanceResult.swap().getOrElse(() => throw StateError('unreachable')),
      );
    }
    final balance =
        balanceResult.getOrElse(() => throw StateError('unreachable'));

    if (amount > balance) {
      return Left(
        BusinessFailure(
          'No tienes saldo suficiente. Disponible: ${balance.toCop()}.',
        ),
      );
    }

    // 6. Canal válido: garantizado por el enum NotificationChannel.
    //    Pasamos directo a las validaciones 7/8 según el canal.

    // 7/8. Email válido si canal=email; teléfono no vacío si canal=sms.
    final userResult = await _userRepository.getUser();
    if (userResult.isLeft()) {
      return Left(
        userResult.swap().getOrElse(() => throw StateError('unreachable')),
      );
    }
    final user = userResult.getOrElse(() => throw StateError('unreachable'));

    if (channel == NotificationChannel.email) {
      if (Validators.email(user.email) != null) {
        return const Left(
          BusinessFailure(
            'Necesitamos un correo válido para enviarte la confirmación.',
          ),
        );
      }
    } else if (channel == NotificationChannel.sms) {
      if (user.phone.trim().isEmpty) {
        return const Left(
          BusinessFailure('Necesitamos tu teléfono para enviarte el SMS.'),
        );
      }
    }

    // ── Todo OK: construir nuevo estado y commit atómico. ──
    final now = _clock();
    final newSub = Subscription(
      id: _uuid.v4(),
      fundId: fund.id,
      fundName: fund.name,
      amount: amount,
      openedAt: now,
      channel: channel,
    );
    final newTx = _addTransactionUseCase.build(
      type: TransactionType.subscription,
      fundId: fund.id,
      fundName: fund.name,
      amount: amount,
      channel: channel,
    );

    final txsResult = await _transactionRepository.getTransactions();
    if (txsResult.isLeft()) {
      return Left(
        txsResult.swap().getOrElse(() => throw StateError('unreachable')),
      );
    }
    final currentTxs =
        txsResult.getOrElse(() => throw StateError('unreachable'));

    final newBalance = balance - amount;
    final newSubsList = [...currentSubs, newSub];
    final newTxsList = [...currentTxs, newTx];

    try {
      await _atomicWrite.commit({
        StorageKeys.userBalance: newBalance.toString(),
        StorageKeys.userSubscriptions: jsonEncode(
          newSubsList
              .map((s) => SubscriptionModel.fromEntity(s).toJson())
              .toList(),
        ),
        StorageKeys.userTransactions: jsonEncode(
          newTxsList
              .map((t) => TransactionModel.fromEntity(t).toJson())
              .toList(),
        ),
      });
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }

    // Best-effort: persistir preferencia de canal fuera del bloque atómico.
    // Si falla, el estado crítico ya quedó persistido; sólo se pierde la
    // preferencia para el siguiente subscribe (no rompe el flujo exitoso).
    try {
      await _userRepository.updateUser(preferredChannel: channel);
    } catch (e) {
      debugPrint(
        'No se pudo persistir el canal preferido (best-effort): $e',
      );
    }

    return Right(newSub);
  }
}
