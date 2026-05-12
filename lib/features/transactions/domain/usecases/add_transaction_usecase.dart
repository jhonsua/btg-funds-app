import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';

import 'package:btg_funds_app/core/clock.dart';
import 'package:btg_funds_app/core/errors/failure.dart';
import 'package:btg_funds_app/features/transactions/domain/entities/transaction.dart';
import 'package:btg_funds_app/features/transactions/domain/entities/transaction_type.dart';
import 'package:btg_funds_app/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:btg_funds_app/features/user/domain/entities/notification_channel.dart';

/// Use case dual: persistencia ([call]) vs. construcción pura ([build]).
///
/// `call()`: persiste la transacción directamente al repositorio.
/// Úsalo desde notifiers o flujos standalone donde quieras escribir
/// una transacción aislada (ej: importar histórico en Etapa 5+).
///
/// `build()`: construye un [Transaction] puro sin side effects.
/// Úsalo desde orquestadores como `SubscribeToFundUseCase` o
/// `CancelSubscriptionUseCase` que YA manejan persistencia atómica
/// vía `AtomicWrite`. Llamar `call()` dentro de esos use cases
/// rompería la atomicidad de las 3 keys.
class AddTransactionUseCase {
  AddTransactionUseCase({
    required TransactionRepository repository,
    required Uuid uuid,
    required Clock clock,
  })  : _repository = repository,
        _uuid = uuid,
        _clock = clock;

  final TransactionRepository _repository;
  final Uuid _uuid;
  final Clock _clock;

  /// Persiste vía repo y retorna el [Transaction] creado.
  Future<Either<Failure, Transaction>> call({
    required TransactionType type,
    required String fundId,
    required String fundName,
    required double amount,
    NotificationChannel? channel,
  }) async {
    final tx = build(
      type: type,
      fundId: fundId,
      fundName: fundName,
      amount: amount,
      channel: channel,
    );
    final result = await _repository.addTransaction(tx);
    return result.fold(Left.new, (_) => Right(tx));
  }

  /// Construye un [Transaction] con id (UUID v4) y `createdAt` (clock)
  /// sin tocar persistencia.
  Transaction build({
    required TransactionType type,
    required String fundId,
    required String fundName,
    required double amount,
    NotificationChannel? channel,
  }) {
    return Transaction(
      id: _uuid.v4(),
      type: type,
      fundId: fundId,
      fundName: fundName,
      amount: amount,
      createdAt: _clock(),
      channel: channel,
    );
  }
}
