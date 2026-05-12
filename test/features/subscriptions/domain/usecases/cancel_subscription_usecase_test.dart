import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:btg_funds_app/core/errors/exceptions.dart';
import 'package:btg_funds_app/core/errors/failure.dart';
import 'package:btg_funds_app/core/storage/storage_keys.dart';
import 'package:btg_funds_app/features/subscriptions/domain/entities/subscription.dart';
import 'package:btg_funds_app/features/subscriptions/domain/usecases/cancel_subscription_usecase.dart';
import 'package:btg_funds_app/features/transactions/domain/entities/transaction.dart';
import 'package:btg_funds_app/features/transactions/domain/entities/transaction_type.dart';
import 'package:btg_funds_app/features/user/domain/entities/notification_channel.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockUserRepository userRepository;
  late MockSubscriptionRepository subscriptionRepository;
  late MockTransactionRepository transactionRepository;
  late MockAddTransactionUseCase addTransactionUseCase;
  late MockAtomicWrite atomicWrite;
  late CancelSubscriptionUseCase useCase;

  final tClock = DateTime.utc(2026, 5, 12, 12);
  final tSubscription = Subscription(
    id: 'sub_1',
    fundId: 'f1',
    fundName: 'Fondo X',
    amount: 100000,
    openedAt: tClock,
    channel: NotificationChannel.email,
  );

  setUpAll(() {
    registerFallbackValue(NotificationChannel.email);
    registerFallbackValue(TransactionType.subscription);
    registerFallbackValue(<String, String>{});
  });

  setUp(() {
    userRepository = MockUserRepository();
    subscriptionRepository = MockSubscriptionRepository();
    transactionRepository = MockTransactionRepository();
    addTransactionUseCase = MockAddTransactionUseCase();
    atomicWrite = MockAtomicWrite();

    when(
      () => addTransactionUseCase.build(
        type: any(named: 'type'),
        fundId: any(named: 'fundId'),
        fundName: any(named: 'fundName'),
        amount: any(named: 'amount'),
        channel: any(named: 'channel'),
      ),
    ).thenReturn(
      Transaction(
        id: 'tx_cancel',
        type: TransactionType.cancellation,
        fundId: tSubscription.fundId,
        fundName: tSubscription.fundName,
        amount: tSubscription.amount,
        createdAt: tClock,
      ),
    );

    useCase = CancelSubscriptionUseCase(
      addTransactionUseCase: addTransactionUseCase,
      atomicWrite: atomicWrite,
      subscriptionRepository: subscriptionRepository,
      transactionRepository: transactionRepository,
      userRepository: userRepository,
    );
  });

  void stubHappy({double balance = 400000}) {
    when(() => subscriptionRepository.getSubscriptions())
        .thenAnswer((_) async => Right([tSubscription]));
    when(() => userRepository.getBalance())
        .thenAnswer((_) async => Right(balance));
    when(() => transactionRepository.getTransactions())
        .thenAnswer((_) async => const Right(<Transaction>[]));
    when(() => atomicWrite.commit(any())).thenAnswer((_) async {});
  }

  group('CancelSubscriptionUseCase', () {
    test('1. happy path → Right(null), AtomicWrite.commit invocado', () async {
      stubHappy();

      final result = await useCase(subscriptionId: 'sub_1');

      expect(result.isRight(), isTrue);
      verify(() => atomicWrite.commit(any())).called(1);
    });

    test('2. subscriptionId no existe → BusinessFailure', () async {
      stubHappy();

      final result = await useCase(subscriptionId: 'no-existe');

      result.fold(
        (failure) {
          expect(failure, isA<BusinessFailure>());
          expect(failure.message, equals('Suscripción no encontrada.'));
        },
        (_) => fail('Debió ser Left'),
      );
      verifyNever(() => atomicWrite.commit(any()));
    });

    test(
      '3. persistencia falla → Left(CacheFailure) propagado desde AtomicWrite',
      () async {
        stubHappy();
        when(() => atomicWrite.commit(any())).thenThrow(
          const CacheException('Falló commit'),
        );

        final result = await useCase(subscriptionId: 'sub_1');

        result.fold(
          (failure) {
            expect(failure, isA<CacheFailure>());
            expect(failure.message, equals('Falló commit'));
          },
          (_) => fail('Debió ser Left'),
        );
      },
    );

    test(
      '4. atomicidad: AtomicWrite falla en userTransactions → '
      'use case retorna Left y no marca éxito',
      () async {
        stubHappy();
        when(() => atomicWrite.commit(any())).thenThrow(
          const CacheException('Falló user.transactions'),
        );

        final result = await useCase(subscriptionId: 'sub_1');

        expect(result.isLeft(), isTrue);
        // Verifica que el use case no asume éxito tras error de atomicWrite.
        result.fold(
          (failure) => expect(failure, isA<CacheFailure>()),
          (_) => fail('Debió ser Left'),
        );
      },
    );

    test(
      '5. atomicidad: AtomicWrite falla en userBalance → use case retorna '
      'Left y la suscripción NO se considera borrada (transparente al caller)',
      () async {
        stubHappy();
        when(() => atomicWrite.commit(any())).thenThrow(
          const CacheException('Falló user.balance'),
        );

        final result = await useCase(subscriptionId: 'sub_1');

        expect(result.isLeft(), isTrue);
        // El AtomicWrite ya hizo rollback internamente (testeado en
        // atomic_write_test.dart). Aquí verificamos que el use case
        // propaga el error sin pretender éxito.
        result.fold(
          (failure) => expect(failure, isA<CacheFailure>()),
          (_) => fail('Debió ser Left'),
        );
      },
    );

    test(
      '6. transaction registrada tiene type=cancellation y channel=null',
      () async {
        stubHappy();
        TransactionType? capturedType;
        NotificationChannel? capturedChannel;
        when(
          () => addTransactionUseCase.build(
            type: any(named: 'type'),
            fundId: any(named: 'fundId'),
            fundName: any(named: 'fundName'),
            amount: any(named: 'amount'),
            channel: any(named: 'channel'),
          ),
        ).thenAnswer((invocation) {
          capturedType = invocation.namedArguments[const Symbol('type')]
              as TransactionType;
          capturedChannel = invocation.namedArguments[const Symbol('channel')]
              as NotificationChannel?;
          return Transaction(
            id: 'tx_cancel',
            type: TransactionType.cancellation,
            fundId: tSubscription.fundId,
            fundName: tSubscription.fundName,
            amount: tSubscription.amount,
            createdAt: tClock,
          );
        });

        await useCase(subscriptionId: 'sub_1');

        expect(capturedType, equals(TransactionType.cancellation));
        expect(capturedChannel, isNull);
      },
    );

    test('7. balance nuevo = balance previo + subscription.amount exacto',
        () async {
      stubHappy();
      Map<String, String>? capturedWrites;
      when(() => atomicWrite.commit(any())).thenAnswer((invocation) async {
        capturedWrites =
            invocation.positionalArguments.first as Map<String, String>;
      });

      await useCase(subscriptionId: 'sub_1');

      expect(capturedWrites, isNotNull);
      final newBalance =
          double.parse(capturedWrites![StorageKeys.userBalance]!);
      expect(newBalance, equals(400000 + tSubscription.amount));
    });

    test(
      '8. después de cancelar la sub no aparece en el nuevo userSubscriptions',
      () async {
        stubHappy();
        Map<String, String>? capturedWrites;
        when(() => atomicWrite.commit(any())).thenAnswer((invocation) async {
          capturedWrites =
              invocation.positionalArguments.first as Map<String, String>;
        });

        await useCase(subscriptionId: 'sub_1');

        final encodedSubs = capturedWrites![StorageKeys.userSubscriptions]!;
        final decoded = jsonDecode(encodedSubs) as List<dynamic>;
        expect(decoded, isEmpty);
      },
    );
  });
}
