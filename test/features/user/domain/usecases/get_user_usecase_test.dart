import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:btg_funds_app/core/constants/app_constants.dart';
import 'package:btg_funds_app/core/errors/failure.dart';
import 'package:btg_funds_app/features/user/domain/entities/user_state.dart';
import 'package:btg_funds_app/features/user/domain/usecases/get_user_usecase.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockUserRepository repository;
  late GetUserUseCase useCase;

  setUp(() {
    repository = MockUserRepository();
    useCase = GetUserUseCase(repository);
  });

  group('GetUserUseCase', () {
    test('retorna Right(UserState) cuando el repositorio responde OK',
        () async {
      const tUser = UserState(
        balance: 425000,
        email: 'usuario@btgpactual.co',
        phone: '+57 300 000 0000',
      );
      when(() => repository.getUser())
          .thenAnswer((_) async => const Right(tUser));

      final result = await useCase();

      expect(result, equals(const Right<Failure, UserState>(tUser)));
      verify(() => repository.getUser()).called(1);
    });

    test('en cold start retorna los defaults canónicos del repositorio',
        () async {
      const tDefaults = UserState(
        balance: kInitialBalance,
        email: kInitialEmail,
        phone: kInitialPhone,
      );
      when(() => repository.getUser())
          .thenAnswer((_) async => const Right(tDefaults));

      final result = await useCase();

      expect(
        result,
        equals(const Right<Failure, UserState>(tDefaults)),
      );
    });

    test('propaga CacheFailure cuando el repositorio falla', () async {
      when(() => repository.getUser()).thenAnswer(
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
    });
  });
}
