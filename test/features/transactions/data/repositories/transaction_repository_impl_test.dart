import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:btg_funds_app/core/errors/exceptions.dart';
import 'package:btg_funds_app/core/errors/failure.dart';
import 'package:btg_funds_app/features/transactions/data/datasources/local_transaction_datasource.dart';
import 'package:btg_funds_app/features/transactions/data/models/transaction_model.dart';
import 'package:btg_funds_app/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:btg_funds_app/features/transactions/domain/entities/transaction.dart';
import 'package:btg_funds_app/features/transactions/domain/entities/transaction_type.dart';

class _MockLocalTxDatasource extends Mock
    implements LocalTransactionDatasource {}

class _FakeTxModel extends Fake implements TransactionModel {}

void main() {
  late _MockLocalTxDatasource datasource;
  late TransactionRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(_FakeTxModel());
  });

  setUp(() {
    datasource = _MockLocalTxDatasource();
    repository = TransactionRepositoryImpl(datasource);
  });

  group('TransactionRepositoryImpl.addTransaction', () {
    test('Right(null) cuando el datasource persiste OK', () async {
      when(() => datasource.addTransaction(any())).thenAnswer((_) async {});

      final tx = Transaction(
        id: 'tx_1',
        type: TransactionType.subscription,
        fundId: 'f1',
        fundName: 'Fondo',
        amount: 100000,
        createdAt: DateTime.utc(2026, 5, 12),
      );

      final result = await repository.addTransaction(tx);

      expect(result.isRight(), isTrue);
    });

    test('CacheException → Left(CacheFailure)', () async {
      when(() => datasource.addTransaction(any()))
          .thenThrow(const CacheException('Disco lleno'));

      final tx = Transaction(
        id: 'tx_1',
        type: TransactionType.cancellation,
        fundId: 'f1',
        fundName: 'Fondo',
        amount: 50000,
        createdAt: DateTime.utc(2026, 5, 12),
      );

      final result = await repository.addTransaction(tx);

      result.fold(
        (failure) {
          expect(failure, isA<CacheFailure>());
          expect(failure.message, equals('Disco lleno'));
        },
        (_) => fail('Debió ser Left'),
      );
    });
  });
}
