import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:btg_funds_app/core/errors/failure.dart';
import 'package:btg_funds_app/features/funds/domain/entities/fund.dart';
import 'package:btg_funds_app/features/funds/domain/usecases/get_funds_usecase.dart';

import '../../../../fixtures/fund_fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late MockFundRepository repository;
  late GetFundsUseCase useCase;

  setUp(() {
    repository = MockFundRepository();
    useCase = GetFundsUseCase(repository);
  });

  group('GetFundsUseCase', () {
    test('retorna Right con los 5 fondos canónicos', () async {
      when(() => repository.getFunds())
          .thenAnswer((_) async => const Right(FundFixtures.all));

      final result = await useCase();

      result.fold(
        (_) => fail('Debió ser Right'),
        (funds) {
          expect(funds.length, equals(5));
          expect(funds.first.id, equals('1'));
        },
      );
    });

    test('retorna Right con lista vacía cuando el repo no tiene fondos',
        () async {
      when(() => repository.getFunds())
          .thenAnswer((_) async => const Right(<Fund>[]));

      final result = await useCase();

      result.fold(
        (_) => fail('Debió ser Right'),
        (funds) => expect(funds, isEmpty),
      );
    });

    test('propaga ServerFailure cuando el repo falla', () async {
      when(() => repository.getFunds()).thenAnswer(
        (_) async => const Left(ServerFailure('Cargar falló')),
      );

      final result = await useCase();

      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, equals('Cargar falló'));
        },
        (_) => fail('Debió ser Left'),
      );
    });
  });
}
