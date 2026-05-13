import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:btg_funds_app/core/errors/exceptions.dart';
import 'package:btg_funds_app/core/errors/failure.dart';
import 'package:btg_funds_app/features/user/data/repositories/user_repository_impl.dart';
import 'package:btg_funds_app/features/user/domain/entities/notification_channel.dart';
import 'package:btg_funds_app/features/user/domain/entities/user_state.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockLocalUserDatasource datasource;
  late UserRepositoryImpl repository;

  const tUser = UserState(
    balance: 500000,
    email: 'usuario@btgpactual.co',
    phone: '+57 300 000 0000',
  );

  const tUpdatedUser = UserState(
    balance: 500000,
    email: 'nuevo@btgpactual.co',
    phone: '+57 300 111 2222',
    preferredChannel: NotificationChannel.sms,
  );

  setUpAll(() {
    registerFallbackValue(NotificationChannel.email);
  });

  setUp(() {
    datasource = MockLocalUserDatasource();
    repository = UserRepositoryImpl(datasource);
  });

  group('UserRepositoryImpl.getUser', () {
    test('datasource retorna UserState → Right(UserState)', () async {
      when(() => datasource.getUser()).thenAnswer((_) async => tUser);

      final result = await repository.getUser();

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Debió ser Right'),
        (user) => expect(user, equals(tUser)),
      );
      verify(() => datasource.getUser()).called(1);
    });

    test(
      'CacheException → Left(CacheFailure) preservando el mensaje',
      () async {
        when(() => datasource.getUser())
            .thenThrow(const CacheException('prefs corruptas'));

        final result = await repository.getUser();

        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) {
            expect(failure, isA<CacheFailure>());
            expect(failure.message, equals('prefs corruptas'));
          },
          (_) => fail('Debió ser Left'),
        );
      },
    );

    test(
      'Excepción genérica → Left(CacheFailure) con mensaje envuelto',
      () async {
        when(() => datasource.getUser()).thenThrow(Exception('inesperado'));

        final result = await repository.getUser();

        result.fold(
          (failure) {
            expect(failure, isA<CacheFailure>());
            expect(failure.message, contains('Error inesperado'));
          },
          (_) => fail('Debió ser Left'),
        );
      },
    );
  });

  group('UserRepositoryImpl.getBalance', () {
    test('datasource retorna saldo → Right(double)', () async {
      when(() => datasource.getBalance()).thenAnswer((_) async => 123456.78);

      final result = await repository.getBalance();

      result.fold(
        (_) => fail('Debió ser Right'),
        (balance) => expect(balance, equals(123456.78)),
      );
      verify(() => datasource.getBalance()).called(1);
    });

    test(
      'CacheException → Left(CacheFailure) preservando el mensaje',
      () async {
        when(() => datasource.getBalance())
            .thenThrow(const CacheException('no se pudo leer saldo'));

        final result = await repository.getBalance();

        result.fold(
          (failure) {
            expect(failure, isA<CacheFailure>());
            expect(failure.message, equals('no se pudo leer saldo'));
          },
          (_) => fail('Debió ser Left'),
        );
      },
    );

    test(
      'Excepción genérica → Left(CacheFailure) con mensaje envuelto',
      () async {
        when(() => datasource.getBalance()).thenThrow(Exception('boom'));

        final result = await repository.getBalance();

        result.fold(
          (failure) {
            expect(failure, isA<CacheFailure>());
            expect(failure.message, contains('Error inesperado'));
          },
          (_) => fail('Debió ser Left'),
        );
      },
    );
  });

  group('UserRepositoryImpl.updateUser', () {
    test(
      'delega los tres campos al datasource y retorna Right(UserState)',
      () async {
        when(
          () => datasource.setUser(
            email: any(named: 'email'),
            phone: any(named: 'phone'),
            preferredChannel: any(named: 'preferredChannel'),
          ),
        ).thenAnswer((_) async => tUpdatedUser);

        final result = await repository.updateUser(
          email: 'nuevo@btgpactual.co',
          phone: '+57 300 111 2222',
          preferredChannel: NotificationChannel.sms,
        );

        result.fold(
          (_) => fail('Debió ser Right'),
          (user) => expect(user, equals(tUpdatedUser)),
        );
        verify(
          () => datasource.setUser(
            email: 'nuevo@btgpactual.co',
            phone: '+57 300 111 2222',
            preferredChannel: NotificationChannel.sms,
          ),
        ).called(1);
      },
    );

    test(
      'propaga campos null al datasource (mutación parcial)',
      () async {
        when(
          () => datasource.setUser(
            email: any(named: 'email'),
            phone: any(named: 'phone'),
            preferredChannel: any(named: 'preferredChannel'),
          ),
        ).thenAnswer(
          (_) async =>
              tUser.copyWith(preferredChannel: NotificationChannel.email),
        );

        final result = await repository.updateUser(
          preferredChannel: NotificationChannel.email,
        );

        result.fold(
          (_) => fail('Debió ser Right'),
          (user) {
            // El resto del estado del usuario se preserva (atomicidad parcial):
            // solo cambia preferredChannel; email y phone siguen siendo los previos.
            expect(user.email, equals(tUser.email));
            expect(user.phone, equals(tUser.phone));
            expect(user.balance, equals(tUser.balance));
            expect(user.preferredChannel, equals(NotificationChannel.email));
          },
        );
        // Verifica que el repositorio NO inventa valores: deja email/phone como
        // null y solo propaga el campo recibido (atomicidad parcial real).
        final captured = verify(
          () => datasource.setUser(
            email: captureAny(named: 'email'),
            phone: captureAny(named: 'phone'),
            preferredChannel: captureAny(named: 'preferredChannel'),
          ),
        ).captured;
        expect(captured[0], isNull);
        expect(captured[1], isNull);
        expect(captured[2], equals(NotificationChannel.email));
      },
    );

    test(
      'CacheException → Left(CacheFailure) preservando el mensaje',
      () async {
        when(
          () => datasource.setUser(
            email: any(named: 'email'),
            phone: any(named: 'phone'),
            preferredChannel: any(named: 'preferredChannel'),
          ),
        ).thenThrow(const CacheException('No se pudo guardar el correo.'));

        final result = await repository.updateUser(email: 'otro@btgpactual.co');

        result.fold(
          (failure) {
            expect(failure, isA<CacheFailure>());
            expect(failure.message, equals('No se pudo guardar el correo.'));
          },
          (_) => fail('Debió ser Left'),
        );
      },
    );

    test(
      'Excepción genérica → Left(CacheFailure) con mensaje envuelto',
      () async {
        when(
          () => datasource.setUser(
            email: any(named: 'email'),
            phone: any(named: 'phone'),
            preferredChannel: any(named: 'preferredChannel'),
          ),
        ).thenThrow(Exception('algo raro'));

        final result = await repository.updateUser(phone: '+57 300 000 0000');

        result.fold(
          (failure) {
            expect(failure, isA<CacheFailure>());
            expect(failure.message, contains('Error inesperado'));
          },
          (_) => fail('Debió ser Left'),
        );
      },
    );
  });

  group('UserRepositoryImpl.setBalance', () {
    test('datasource OK → Right(null)', () async {
      when(() => datasource.setBalance(any())).thenAnswer((_) async {});

      final result = await repository.setBalance(999.99);

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Debió ser Right'),
        (_) {},
      );
      verify(() => datasource.setBalance(999.99)).called(1);
    });

    test(
      'CacheException → Left(CacheFailure) preservando el mensaje',
      () async {
        when(() => datasource.setBalance(any()))
            .thenThrow(const CacheException('No se pudo guardar el saldo.'));

        final result = await repository.setBalance(1.0);

        result.fold(
          (failure) {
            expect(failure, isA<CacheFailure>());
            expect(failure.message, equals('No se pudo guardar el saldo.'));
          },
          (_) => fail('Debió ser Left'),
        );
      },
    );

    test(
      'Excepción genérica → Left(CacheFailure) con mensaje envuelto',
      () async {
        when(() => datasource.setBalance(any())).thenThrow(Exception('io'));

        final result = await repository.setBalance(0);

        result.fold(
          (failure) {
            expect(failure, isA<CacheFailure>());
            expect(failure.message, contains('Error inesperado'));
          },
          (_) => fail('Debió ser Left'),
        );
      },
    );
  });

  group('UserRepositoryImpl.resetToDefaults', () {
    test('datasource OK → Right(UserState defaults)', () async {
      when(() => datasource.reset()).thenAnswer((_) async => tUser);

      final result = await repository.resetToDefaults();

      result.fold(
        (_) => fail('Debió ser Right'),
        (user) => expect(user, equals(tUser)),
      );
      verify(() => datasource.reset()).called(1);
    });

    test(
      'CacheException → Left(CacheFailure) preservando el mensaje',
      () async {
        when(() => datasource.reset()).thenThrow(
          const CacheException('Error restableciendo la cuenta de demo'),
        );

        final result = await repository.resetToDefaults();

        result.fold(
          (failure) {
            expect(failure, isA<CacheFailure>());
            expect(
              failure.message,
              equals('Error restableciendo la cuenta de demo'),
            );
          },
          (_) => fail('Debió ser Left'),
        );
      },
    );

    test(
      'Excepción genérica → Left(CacheFailure) con mensaje envuelto',
      () async {
        when(() => datasource.reset()).thenThrow(Exception('rare'));

        final result = await repository.resetToDefaults();

        result.fold(
          (failure) {
            expect(failure, isA<CacheFailure>());
            expect(failure.message, contains('Error inesperado'));
          },
          (_) => fail('Debió ser Left'),
        );
      },
    );
  });
}
