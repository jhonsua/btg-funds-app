import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:btg_funds_app/core/errors/failure.dart';
import 'package:btg_funds_app/features/user/domain/entities/notification_channel.dart';
import 'package:btg_funds_app/features/user/domain/entities/user_state.dart';
import 'package:btg_funds_app/features/user/domain/usecases/update_user_usecase.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockUserRepository repository;
  late UpdateUserUseCase useCase;

  setUpAll(() {
    registerFallbackValue(NotificationChannel.email);
  });

  setUp(() {
    repository = MockUserRepository();
    useCase = UpdateUserUseCase(repository);
  });

  const tUpdatedUser = UserState(
    balance: 500000,
    email: 'nuevo@btgpactual.co',
    phone: '+57 300 111 2222',
  );

  void stubRepoSuccess() {
    when(
      () => repository.updateUser(
        email: any(named: 'email'),
        phone: any(named: 'phone'),
        preferredChannel: any(named: 'preferredChannel'),
      ),
    ).thenAnswer((_) async => const Right(tUpdatedUser));
  }

  void stubRepoFailure(Failure failure) {
    when(
      () => repository.updateUser(
        email: any(named: 'email'),
        phone: any(named: 'phone'),
        preferredChannel: any(named: 'preferredChannel'),
      ),
    ).thenAnswer((_) async => Left(failure));
  }

  void verifyNeverCalledRepo() {
    verifyNever(
      () => repository.updateUser(
        email: any(named: 'email'),
        phone: any(named: 'phone'),
        preferredChannel: any(named: 'preferredChannel'),
      ),
    );
  }

  group('UpdateUserUseCase', () {
    test('retorna BusinessFailure cuando el email es inválido', () async {
      final result = await useCase(email: 'sin-arroba');

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<BusinessFailure>());
          expect(failure.message, contains('Correo'));
        },
        (_) => fail('Debió retornar Left'),
      );
      verifyNeverCalledRepo();
    });

    test('retorna BusinessFailure cuando el teléfono es inválido', () async {
      final result = await useCase(phone: '3001234567');

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<BusinessFailure>());
          expect(failure.message, contains('Teléfono'));
        },
        (_) => fail('Debió retornar Left'),
      );
      verifyNeverCalledRepo();
    });

    test(
      'retorna BusinessFailure por email cuando ambos son inválidos',
      () async {
        final result = await useCase(email: 'bad', phone: 'tampoco');

        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) {
            // Email valida primero → su error es el reportado.
            expect(failure, isA<BusinessFailure>());
            expect(failure.message, contains('Correo'));
          },
          (_) => fail('Debió retornar Left'),
        );
      },
    );

    test(
      'llama al repo y retorna Right cuando email y phone son válidos',
      () async {
        stubRepoSuccess();

        final result = await useCase(
          email: 'nuevo@btgpactual.co',
          phone: '+57 300 111 2222',
          preferredChannel: NotificationChannel.sms,
        );

        expect(result, equals(const Right<Failure, UserState>(tUpdatedUser)));
        verify(
          () => repository.updateUser(
            email: 'nuevo@btgpactual.co',
            phone: '+57 300 111 2222',
            preferredChannel: NotificationChannel.sms,
          ),
        ).called(1);
      },
    );

    test(
      'con sólo preferredChannel llama al repo sin validar email/phone',
      () async {
        stubRepoSuccess();

        final result = await useCase(preferredChannel: NotificationChannel.sms);

        expect(result.isRight(), isTrue);
        verify(
          () => repository.updateUser(
            preferredChannel: NotificationChannel.sms,
          ),
        ).called(1);
      },
    );

    test('propaga CacheFailure cuando la persistencia falla', () async {
      stubRepoFailure(const CacheFailure('Disco lleno'));

      final result = await useCase(email: 'nuevo@btgpactual.co');

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<CacheFailure>());
          expect(failure.message, equals('Disco lleno'));
        },
        (_) => fail('Debió retornar Left'),
      );
    });
  });
}
