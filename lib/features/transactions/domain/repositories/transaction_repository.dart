import 'package:dartz/dartz.dart';

import 'package:btg_funds_app/core/errors/failure.dart';
import 'package:btg_funds_app/features/transactions/domain/entities/transaction.dart';

abstract class TransactionRepository {
  Future<Either<Failure, List<Transaction>>> getTransactions();

  /// Persiste una transacción independiente (uso esperado: importar histórico
  /// en Etapa 5+). Los flujos atómicos de suscripción/cancelación NO usan
  /// este método — escriben directamente vía `AtomicWrite` para mantener
  /// la atomicidad de las 3 keys.
  Future<Either<Failure, void>> addTransaction(Transaction tx);
}
