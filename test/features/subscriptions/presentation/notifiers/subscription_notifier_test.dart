import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:btg_funds_app/core/errors/failure.dart';
import 'package:btg_funds_app/features/subscriptions/domain/entities/subscription.dart';
import 'package:btg_funds_app/features/subscriptions/domain/usecases/cancel_subscription_usecase.dart';
import 'package:btg_funds_app/features/subscriptions/domain/usecases/subscribe_to_fund_usecase.dart';
import 'package:btg_funds_app/features/subscriptions/presentation/notifiers/subscription_state.dart';
import 'package:btg_funds_app/features/subscriptions/presentation/providers/providers.dart';
import 'package:btg_funds_app/features/transactions/domain/entities/transaction.dart';
import 'package:btg_funds_app/features/transactions/domain/entities/transaction_filter.dart';
import 'package:btg_funds_app/features/transactions/presentation/providers/providers.dart';
import 'package:btg_funds_app/features/user/domain/entities/notification_channel.dart';

import '../../../../helpers/mocks.dart';

class _MockSubscribe extends Mock implements SubscribeToFundUseCase {}

class _MockCancel extends Mock implements CancelSubscriptionUseCase {}

class _FakeFilter extends Fake implements TransactionFilter {}

void main() {
  late _MockSubscribe subscribeUseCase;
  late _MockCancel cancelUseCase;
  late MockGetTransactionsUseCase getTransactionsUseCase;
  late ProviderContainer container;

  final tClock = DateTime.utc(2026, 5, 12, 12);
  final tSub = Subscription(
    id: 'sub_1',
    fundId: 'f1',
    fundName: 'Fondo X',
    amount: 100000,
    openedAt: tClock,
    channel: NotificationChannel.email,
  );

  setUpAll(() {
    registerFallbackValue(NotificationChannel.email);
    registerFallbackValue(_FakeFilter());
  });

  setUp(() {
    subscribeUseCase = _MockSubscribe();
    cancelUseCase = _MockCancel();
    getTransactionsUseCase = MockGetTransactionsUseCase();
    when(
      () => getTransactionsUseCase(any()),
    ).thenAnswer((_) async => const Right(<Transaction>[]));
    container = ProviderContainer(
      overrides: [
        subscribeToFundUseCaseProvider.overrideWithValue(subscribeUseCase),
        cancelSubscriptionUseCaseProvider.overrideWithValue(cancelUseCase),
        getTransactionsUseCaseProvider
            .overrideWithValue(getTransactionsUseCase),
      ],
    );
    addTearDown(container.dispose);
  });

  group('SubscriptionNotifier', () {
    test('estado inicial es SubscriptionState.idle', () {
      final state = container.read(subscriptionNotifierProvider);
      expect(state, equals(const SubscriptionState.idle()));
    });

    test(
      'subscribe en path Right → SubscriptionState.success y lastError null',
      () async {
        when(
          () => subscribeUseCase(
            fundId: any(named: 'fundId'),
            amount: any(named: 'amount'),
            channel: any(named: 'channel'),
          ),
        ).thenAnswer((_) async => Right(tSub));

        final notifier = container.read(subscriptionNotifierProvider.notifier);
        final ok = await notifier.subscribe(
          fundId: 'f1',
          amount: 100000,
          channel: NotificationChannel.email,
        );

        expect(ok, isTrue);
        expect(
          container.read(subscriptionNotifierProvider),
          equals(SubscriptionState.success(tSub)),
        );
        expect(notifier.lastError, isNull);
      },
    );

    test(
      'subscribe en path Left → SubscriptionState.error y lastError seteado',
      () async {
        when(
          () => subscribeUseCase(
            fundId: any(named: 'fundId'),
            amount: any(named: 'amount'),
            channel: any(named: 'channel'),
          ),
        ).thenAnswer(
          (_) async => const Left(BusinessFailure('Saldo insuficiente')),
        );

        final notifier = container.read(subscriptionNotifierProvider.notifier);
        final ok = await notifier.subscribe(
          fundId: 'f1',
          amount: 999999,
          channel: NotificationChannel.email,
        );

        expect(ok, isFalse);
        expect(notifier.lastError, equals('Saldo insuficiente'));
        expect(
          container.read(subscriptionNotifierProvider),
          equals(const SubscriptionState.error('Saldo insuficiente')),
        );
      },
    );

    test('cancel en path Right → SubscriptionState.cancelled', () async {
      when(() => cancelUseCase(subscriptionId: any(named: 'subscriptionId')))
          .thenAnswer((_) async => const Right(null));

      final notifier = container.read(subscriptionNotifierProvider.notifier);
      final ok = await notifier.cancel(subscriptionId: 'sub_1');

      expect(ok, isTrue);
      expect(
        container.read(subscriptionNotifierProvider),
        equals(const SubscriptionState.cancelled()),
      );
      expect(notifier.lastError, isNull);
    });

    test(
      'subscribe exitoso invalida transactionsNotifierProvider '
      '(re-ejecuta getTransactions tras el rebuild)',
      () async {
        when(
          () => subscribeUseCase(
            fundId: any(named: 'fundId'),
            amount: any(named: 'amount'),
            channel: any(named: 'channel'),
          ),
        ).thenAnswer((_) async => Right(tSub));

        // 1. Pre: leer el future para que el provider construya y consuma 1 llamada.
        await container.read(transactionsNotifierProvider.future);
        verify(() => getTransactionsUseCase(any())).called(1);

        // 2. Ejecutar la mutación.
        await container.read(subscriptionNotifierProvider.notifier).subscribe(
              fundId: 'f1',
              amount: 100000,
              channel: NotificationChannel.email,
            );

        // 3. Post: leer DE NUEVO el future para forzar rebuild tras invalidate.
        await container.read(transactionsNotifierProvider.future);
        verify(() => getTransactionsUseCase(any())).called(1);
      },
    );

    test(
      'cancel exitoso invalida transactionsNotifierProvider '
      '(re-ejecuta getTransactions tras el rebuild)',
      () async {
        when(() => cancelUseCase(subscriptionId: any(named: 'subscriptionId')))
            .thenAnswer((_) async => const Right(null));

        // 1. Pre.
        await container.read(transactionsNotifierProvider.future);
        verify(() => getTransactionsUseCase(any())).called(1);

        // 2. Mutación.
        await container
            .read(subscriptionNotifierProvider.notifier)
            .cancel(subscriptionId: 'sub_1');

        // 3. Post: segundo read fuerza el rebuild.
        await container.read(transactionsNotifierProvider.future);
        verify(() => getTransactionsUseCase(any())).called(1);
      },
    );
  });
}
