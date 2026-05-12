import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:btg_funds_app/core/errors/failure.dart';
import 'package:btg_funds_app/features/user/domain/entities/notification_channel.dart';
import 'package:btg_funds_app/features/user/domain/entities/user_state.dart';
import 'package:btg_funds_app/features/user/presentation/providers/providers.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockGetUserUseCase getUser;
  late MockUpdateUserUseCase updateUser;
  late MockResetDemoUseCase resetDemo;
  late ProviderContainer container;

  const tInitialUser = UserState(
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
    getUser = MockGetUserUseCase();
    updateUser = MockUpdateUserUseCase();
    resetDemo = MockResetDemoUseCase();

    when(() => getUser()).thenAnswer((_) async => const Right(tInitialUser));

    container = ProviderContainer(
      overrides: [
        getUserUseCaseProvider.overrideWithValue(getUser),
        updateUserUseCaseProvider.overrideWithValue(updateUser),
        resetDemoUseCaseProvider.overrideWithValue(resetDemo),
      ],
    );
    addTearDown(container.dispose);
  });

  group('UserNotifier', () {
    test('build() carga el usuario y deja state en AsyncData', () async {
      final user = await container.read(userNotifierProvider.future);

      expect(user, equals(tInitialUser));
      expect(
        container.read(userNotifierProvider),
        equals(const AsyncData<UserState>(tInitialUser)),
      );
      expect(
        container.read(userNotifierProvider.notifier).lastError,
        isNull,
      );
    });

    test('updateProfile en path Right deja AsyncData con valores nuevos',
        () async {
      await container.read(userNotifierProvider.future);
      when(
        () => updateUser(
          email: any(named: 'email'),
          phone: any(named: 'phone'),
          preferredChannel: any(named: 'preferredChannel'),
        ),
      ).thenAnswer((_) async => const Right(tUpdatedUser));

      final notifier = container.read(userNotifierProvider.notifier);
      final ok = await notifier.updateProfile(
        email: 'nuevo@btgpactual.co',
        phone: '+57 300 111 2222',
        preferredChannel: NotificationChannel.sms,
      );

      expect(ok, isTrue);
      expect(notifier.lastError, isNull);
      expect(
        container.read(userNotifierProvider).valueOrNull,
        equals(tUpdatedUser),
      );
    });

    test('updateProfile en path Left setea lastError y state queda AsyncError',
        () async {
      await container.read(userNotifierProvider.future);
      when(
        () => updateUser(
          email: any(named: 'email'),
          phone: any(named: 'phone'),
          preferredChannel: any(named: 'preferredChannel'),
        ),
      ).thenAnswer(
        (_) async => const Left(BusinessFailure('Correo inválido.')),
      );

      final notifier = container.read(userNotifierProvider.notifier);
      final ok = await notifier.updateProfile(email: 'bad');

      expect(ok, isFalse);
      expect(notifier.lastError, equals('Correo inválido.'));
      expect(container.read(userNotifierProvider).hasError, isTrue);
    });

    test('resetDemo en path Right deja AsyncData con el usuario fresco',
        () async {
      await container.read(userNotifierProvider.future);
      when(() => resetDemo())
          .thenAnswer((_) async => const Right(tInitialUser));

      final notifier = container.read(userNotifierProvider.notifier);
      final ok = await notifier.resetDemo();

      expect(ok, isTrue);
      expect(notifier.lastError, isNull);
      expect(
        container.read(userNotifierProvider).valueOrNull,
        equals(tInitialUser),
      );
    });
  });
}
