import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:btg_funds_app/core/errors/exceptions.dart';
import 'package:btg_funds_app/core/errors/failure.dart';
import 'package:btg_funds_app/features/funds/data/models/fund_model.dart';
import 'package:btg_funds_app/features/funds/data/repositories/fund_repository_impl.dart';
import 'package:btg_funds_app/features/funds/domain/entities/fund.dart';
import 'package:btg_funds_app/features/funds/domain/entities/fund_category.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockFundRemoteDatasource datasource;
  late FundRepositoryImpl repository;

  setUp(() {
    datasource = MockFundRemoteDatasource();
    repository = FundRepositoryImpl(datasource);
  });

  const tModel = FundModel(
    id: '1',
    name: 'FPV_BTG_PACTUAL_RECAUDADORA',
    minimumAmount: 75000,
    category: FundCategory.fpv,
    description: 'desc',
  );

  group('FundRepositoryImpl.getFunds', () {
    test('mapea modelos a entidades y retorna Right', () async {
      when(() => datasource.getFunds()).thenAnswer((_) async => [tModel]);

      final result = await repository.getFunds();

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Debió ser Right'),
        (funds) {
          expect(funds.length, equals(1));
          expect(funds.first, isA<Fund>());
          expect(funds.first.id, equals('1'));
        },
      );
    });

    test('ServerException → Left(ServerFailure) con el mismo mensaje',
        () async {
      when(() => datasource.getFunds())
          .thenThrow(const ServerException('JSON corrupto'));

      final result = await repository.getFunds();

      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, equals('JSON corrupto'));
        },
        (_) => fail('Debió ser Left'),
      );
    });

    test('Excepción genérica → Left(ServerFailure)', () async {
      when(() => datasource.getFunds()).thenThrow(Exception('inesperado'));

      final result = await repository.getFunds();

      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Debió ser Left'),
      );
    });
  });

  group('FundRepositoryImpl.getFundById', () {
    test('datasource retorna null → Left(BusinessFailure)', () async {
      when(() => datasource.getFundById(any())).thenAnswer((_) async => null);

      final result = await repository.getFundById('999');

      result.fold(
        (failure) {
          expect(failure, isA<BusinessFailure>());
          expect(failure.message, equals('Fondo no disponible.'));
        },
        (_) => fail('Debió ser Left'),
      );
    });
  });
}
