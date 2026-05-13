import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:btg_funds_app/core/errors/failure.dart';
import 'package:btg_funds_app/features/subscriptions/domain/entities/subscription.dart';
import 'package:btg_funds_app/features/subscriptions/domain/usecases/get_subscriptions_usecase.dart';
import 'package:btg_funds_app/features/subscriptions/presentation/providers/providers.dart';
import 'package:btg_funds_app/features/transactions/domain/entities/transaction.dart';
import 'package:btg_funds_app/features/transactions/domain/entities/transaction_filter.dart';
import 'package:btg_funds_app/features/transactions/presentation/providers/providers.dart';
import 'package:btg_funds_app/features/user/domain/entities/notification_channel.dart';
import 'package:btg_funds_app/features/user/domain/entities/user_state.dart';
import 'package:btg_funds_app/features/user/presentation/providers/providers.dart';

import '../../../../helpers/mocks.dart';

class _MockGetSubscriptionsUseCase extends Mock
    implements GetSubscriptionsUseCase {}

class _FakeFilter extends Fake implements TransactionFilter {}

void main() {
  late MockGetUserUseCase getUser;
  late MockUpdateUserUseCase updateUser;
  late MockResetDemoUseCase resetDemo;
  late _MockGetSubscriptionsUseCase getSubscriptions;
  late MockGetTransactionsUseCase getTransactions;
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
    registerFallbackValue(_FakeFilter());
  });

  setUp(() {
    getUser = MockGetUserUseCase();
    updateUser = MockUpdateUserUseCase();
    resetDemo = MockResetDemoUseCase();
    getSubscriptions = _MockGetSubscriptionsUseCase();
    getTransactions = MockGetTransactionsUseCase();

    when(() => getUser()).thenAnswer((_) async => const Right(tInitialUser));
    when(() => getSubscriptions())
        .thenAnswer((_) async => const Right(<Subscription>[]));
    when(() => getTransactions(any()))
        .thenAnswer((_) async => const Right(<Transaction>[]));

    container = ProviderContainer(
      overrides: [
        getUserUseCaseProvider.overrideWithValue(getUser),
        updateUserUseCaseProvider.overrideWithValue(updateUser),
        resetDemoUseCaseProvider.overrideWithValue(resetDemo),
        getSubscriptionsUseCaseProvider.overrideWithValue(getSubscriptions),
        getTransactionsUseCaseProvider.overrideWithValue(getTransactions),
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

    test(
      'resetDemo exitoso invalida subscriptionsListNotifierProvider y '
      'transactionsNotifierProvider (re-ejecutan sus use cases tras rebuild)',
      () async {
        await container.read(userNotifierProvider.future);
        when(() => resetDemo())
            .thenAnswer((_) async => const Right(tInitialUser));

        // 1. Pre: leer los dos providers dependientes para que construyan
        //    y consuman 1 llamada cada uno.
        await container.read(subscriptionsListNotifierProvider.future);
        await container.read(transactionsNotifierProvider.future);
        verify(() => getSubscriptions()).called(1);
        verify(() => getTransactions(any())).called(1);

        // 2. Ejecutar el reset.
        final ok =
            await container.read(userNotifierProvider.notifier).resetDemo();
        expect(ok, isTrue);

        // 3. Post: leer DE NUEVO los providers fuerza rebuild tras invalidate.
        await container.read(subscriptionsListNotifierProvider.future);
        await container.read(transactionsNotifierProvider.future);
        verify(() => getSubscriptions()).called(1);
        verify(() => getTransactions(any())).called(1);
      },
    );

    test(
      'resetDemo en path Left NO invalida los providers dependientes',
      () async {
        await container.read(userNotifierProvider.future);
        when(() => resetDemo()).thenAnswer(
          (_) async => const Left(CacheFailure('Falló reset')),
        );

        // Pre.
        await container.read(subscriptionsListNotifierProvider.future);
        await container.read(transactionsNotifierProvider.future);
        verify(() => getSubscriptions()).called(1);
        verify(() => getTransactions(any())).called(1);

        // Reset falla.
        final ok =
            await container.read(userNotifierProvider.notifier).resetDemo();
        expect(ok, isFalse);

        // Los providers NO se invalidan: una nueva lectura NO dispara los use cases.
        container.read(subscriptionsListNotifierProvider);
        container.read(transactionsNotifierProvider);
        verifyNever(() => getSubscriptions());
        verifyNever(() => getTransactions(any()));
      },
    );
  });
}
