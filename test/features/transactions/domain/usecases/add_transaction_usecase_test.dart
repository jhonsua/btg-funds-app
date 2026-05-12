import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:btg_funds_app/core/errors/failure.dart';
import 'package:btg_funds_app/features/transactions/domain/entities/transaction.dart';
import 'package:btg_funds_app/features/transactions/domain/entities/transaction_type.dart';
import 'package:btg_funds_app/features/transactions/domain/usecases/add_transaction_usecase.dart';

import '../../../../helpers/mocks.dart';

class _FakeTransaction extends Fake implements Transaction {}

void main() {
  late MockTransactionRepository repository;
  late MockUuid uuid;
  late AddTransactionUseCase useCase;

  final tNow = DateTime.utc(2026, 5, 12, 12);

  setUpAll(() {
    registerFallbackValue(_FakeTransaction());
  });

  setUp(() {
    repository = MockTransactionRepository();
    uuid = MockUuid();
    when(() => uuid.v4()).thenReturn('tx_fixed');
    useCase = AddTransactionUseCase(
      repository: repository,
      uuid: uuid,
      clock: () => tNow,
    );
  });

  group('AddTransactionUseCase.call', () {
    test('persiste y retorna Right(Transaction) cuando el repo escribe OK',
        () async {
      when(() => repository.addTransaction(any()))
          .thenAnswer((_) async => const Right(null));

      final result = await useCase(
        type: TransactionType.subscription,
        fundId: 'f1',
        fundName: 'Fondo X',
        amount: 100000,
      );

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Debió ser Right'),
        (tx) {
          expect(tx.id, equals('tx_fixed'));
          expect(tx.type, equals(TransactionType.subscription));
          expect(tx.createdAt, equals(tNow));
        },
      );
      verify(() => repository.addTransaction(any())).called(1);
    });

    test('propaga Left cuando el repo falla', () async {
      when(() => repository.addTransaction(any())).thenAnswer(
        (_) async => const Left(CacheFailure('Disco lleno')),
      );

      final result = await useCase(
        type: TransactionType.cancellation,
        fundId: 'f1',
        fundName: 'Fondo X',
        amount: 50000,
      );

      result.fold(
        (failure) => expect(failure, isA<CacheFailure>()),
        (_) => fail('Debió ser Left'),
      );
    });
  });
}
