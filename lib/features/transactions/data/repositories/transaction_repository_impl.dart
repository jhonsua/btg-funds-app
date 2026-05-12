import 'package:dartz/dartz.dart';

import 'package:btg_funds_app/core/errors/exceptions.dart';
import 'package:btg_funds_app/core/errors/failure.dart';
import 'package:btg_funds_app/features/transactions/data/datasources/local_transaction_datasource.dart';
import 'package:btg_funds_app/features/transactions/data/models/transaction_model.dart';
import 'package:btg_funds_app/features/transactions/domain/entities/transaction.dart';
import 'package:btg_funds_app/features/transactions/domain/repositories/transaction_repository.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  TransactionRepositoryImpl(this._datasource);

  final LocalTransactionDatasource _datasource;

  @override
  Future<Either<Failure, List<Transaction>>> getTransactions() async {
    try {
      final models = await _datasource.getTransactions();
      return Right(models.map((m) => m.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> addTransaction(Transaction tx) async {
    try {
      await _datasource.addTransaction(TransactionModel.fromEntity(tx));
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Error inesperado: $e'));
    }
  }
}
