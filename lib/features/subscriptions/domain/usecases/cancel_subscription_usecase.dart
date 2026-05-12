import 'dart:convert';

import 'package:dartz/dartz.dart';

import 'package:btg_funds_app/core/errors/exceptions.dart';
import 'package:btg_funds_app/core/errors/failure.dart';
import 'package:btg_funds_app/core/storage/atomic_write.dart';
import 'package:btg_funds_app/core/storage/storage_keys.dart';
import 'package:btg_funds_app/features/subscriptions/data/models/subscription_model.dart';
import 'package:btg_funds_app/features/subscriptions/domain/repositories/subscription_repository.dart';
import 'package:btg_funds_app/features/transactions/data/models/transaction_model.dart';
import 'package:btg_funds_app/features/transactions/domain/entities/transaction_type.dart';
import 'package:btg_funds_app/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:btg_funds_app/features/transactions/domain/usecases/add_transaction_usecase.dart';
import 'package:btg_funds_app/features/user/domain/repositories/user_repository.dart';

/// Cancela una suscripción activa: devuelve el monto al saldo, elimina la
/// suscripción de la lista y registra la transacción tipo `cancellation`,
/// todo atómicamente vía [AtomicWrite].
///
/// La confirmación al usuario ("¿Estás seguro?") es responsabilidad de la
/// UI (Etapa 6), no del use case (SPEC_FUNCIONAL §5.2).
class CancelSubscriptionUseCase {
  CancelSubscriptionUseCase({
    required AddTransactionUseCase addTransactionUseCase,
    required AtomicWrite atomicWrite,
    required SubscriptionRepository subscriptionRepository,
    required TransactionRepository transactionRepository,
    required UserRepository userRepository,
  })  : _addTransactionUseCase = addTransactionUseCase,
        _atomicWrite = atomicWrite,
        _subscriptionRepository = subscriptionRepository,
        _transactionRepository = transactionRepository,
        _userRepository = userRepository;

  final AddTransactionUseCase _addTransactionUseCase;
  final AtomicWrite _atomicWrite;
  final SubscriptionRepository _subscriptionRepository;
  final TransactionRepository _transactionRepository;
  final UserRepository _userRepository;

  Future<Either<Failure, void>> call({required String subscriptionId}) async {
    final subsResult = await _subscriptionRepository.getSubscriptions();
    if (subsResult.isLeft()) {
      return Left(
        subsResult.swap().getOrElse(() => throw StateError('unreachable')),
      );
    }
    final currentSubs =
        subsResult.getOrElse(() => throw StateError('unreachable'));

    final matches = currentSubs.where((s) => s.id == subscriptionId).toList();
    if (matches.isEmpty) {
      return const Left(BusinessFailure('Suscripción no encontrada.'));
    }
    final target = matches.first;

    final balanceResult = await _userRepository.getBalance();
    if (balanceResult.isLeft()) {
      return Left(
        balanceResult.swap().getOrElse(() => throw StateError('unreachable')),
      );
    }
    final balance =
        balanceResult.getOrElse(() => throw StateError('unreachable'));

    final txsResult = await _transactionRepository.getTransactions();
    if (txsResult.isLeft()) {
      return Left(
        txsResult.swap().getOrElse(() => throw StateError('unreachable')),
      );
    }
    final currentTxs =
        txsResult.getOrElse(() => throw StateError('unreachable'));

    final newBalance = balance + target.amount;
    final newSubsList =
        currentSubs.where((s) => s.id != subscriptionId).toList();
    final newTx = _addTransactionUseCase.build(
      type: TransactionType.cancellation,
      fundId: target.fundId,
      fundName: target.fundName,
      amount: target.amount,
    );
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

    return const Right(null);
  }
}
