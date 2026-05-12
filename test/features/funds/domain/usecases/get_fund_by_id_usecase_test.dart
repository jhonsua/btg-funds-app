import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:btg_funds_app/core/errors/failure.dart';
import 'package:btg_funds_app/features/funds/domain/entities/fund.dart';
import 'package:btg_funds_app/features/funds/domain/usecases/get_fund_by_id_usecase.dart';

import '../../../../fixtures/fund_fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late MockFundRepository repository;
  late GetFundByIdUseCase useCase;

  setUp(() {
    repository = MockFundRepository();
    useCase = GetFundByIdUseCase(repository);
  });

  group('GetFundByIdUseCase', () {
    test('retorna Right con el fondo cuando el id existe', () async {
      when(() => repository.getFundById('1'))
          .thenAnswer((_) async => const Right(FundFixtures.recaudadora));

      final result = await useCase('1');

      expect(
        result,
        equals(const Right<Failure, Fund>(FundFixtures.recaudadora)),
      );
    });

    test('retorna Left(BusinessFailure) cuando el id no existe', () async {
      when(() => repository.getFundById('999')).thenAnswer(
        (_) async => const Left(BusinessFailure('Fondo no disponible.')),
      );

      final result = await useCase('999');

      result.fold(
        (failure) {
          expect(failure, isA<BusinessFailure>());
          expect(failure.message, equals('Fondo no disponible.'));
        },
        (_) => fail('Debió ser Left'),
      );
    });

    test('propaga ServerFailure cuando el repo falla', () async {
      when(() => repository.getFundById(any())).thenAnswer(
        (_) async => const Left(ServerFailure('Backend off')),
      );

      final result = await useCase('1');

      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Debió ser Left'),
      );
    });
  });
}
