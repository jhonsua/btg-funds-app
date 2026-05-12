import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:btg_funds_app/core/constants/app_constants.dart';
import 'package:btg_funds_app/core/errors/failure.dart';
import 'package:btg_funds_app/features/user/domain/entities/user_state.dart';
import 'package:btg_funds_app/features/user/domain/usecases/reset_demo_usecase.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockUserRepository repository;
  late ResetDemoUseCase useCase;

  setUp(() {
    repository = MockUserRepository();
    useCase = ResetDemoUseCase(repository);
  });

  const tFreshUser = UserState(
    balance: kInitialBalance,
    email: kInitialEmail,
    phone: kInitialPhone,
  );

  group('ResetDemoUseCase', () {
    // NOTA Etapa 4: agregar test "bloqueado por operación pendiente" cuando
    // existan SubscriptionNotifier/TransactionsNotifier y se inyecte el lock
    // (ver TODO en reset_demo_usecase.dart y SPEC_FUNCIONAL §7).

    test('retorna Right con UserState fresco cuando el repo restablece OK',
        () async {
      when(() => repository.resetToDefaults())
          .thenAnswer((_) async => const Right(tFreshUser));

      final result = await useCase();

      expect(result, equals(const Right<Failure, UserState>(tFreshUser)));
      verify(() => repository.resetToDefaults()).called(1);
    });

    test('propaga CacheFailure cuando el repositorio falla', () async {
      when(() => repository.resetToDefaults()).thenAnswer(
        (_) async => const Left(CacheFailure('No se pudo limpiar el disco')),
      );

      final result = await useCase();

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<CacheFailure>());
          expect(failure.message, equals('No se pudo limpiar el disco'));
        },
        (_) => fail('Debió retornar Left'),
      );
    });
  });
}
