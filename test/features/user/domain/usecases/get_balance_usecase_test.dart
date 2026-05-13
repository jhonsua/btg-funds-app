import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:btg_funds_app/core/errors/failure.dart';
import 'package:btg_funds_app/features/user/domain/usecases/get_balance_usecase.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockUserRepository repository;
  late GetBalanceUseCase useCase;

  setUp(() {
    repository = MockUserRepository();
    useCase = GetBalanceUseCase(repository);
  });

  group('GetBalanceUseCase', () {
    test('retorna Right(balance) cuando el repositorio responde OK', () async {
      const tBalance = 500000.0;
      when(() => repository.getBalance())
          .thenAnswer((_) async => const Right(tBalance));

      final result = await useCase();

      expect(result, equals(const Right<Failure, double>(tBalance)));
      verify(() => repository.getBalance()).called(1);
    });

    test('propaga el balance exacto del repositorio sin transformaciones',
        () async {
      const tBalance = 1234567.89;
      when(() => repository.getBalance())
          .thenAnswer((_) async => const Right(tBalance));

      final result = await useCase();

      expect(
        result,
        equals(const Right<Failure, double>(tBalance)),
      );
    });

    test('propaga CacheFailure cuando el repositorio falla', () async {
      when(() => repository.getBalance()).thenAnswer(
        (_) async => const Left(CacheFailure('Error de disco')),
      );

      final result = await useCase();

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<CacheFailure>());
          expect(failure.message, equals('Error de disco'));
        },
        (_) => fail('Debió retornar Left'),
      );
      verify(() => repository.getBalance()).called(1);
    });
  });
}
