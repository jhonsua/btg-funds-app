import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:btg_funds_app/core/errors/exceptions.dart';
import 'package:btg_funds_app/core/errors/failure.dart';
import 'package:btg_funds_app/features/subscriptions/domain/entities/subscription.dart';
import 'package:btg_funds_app/features/subscriptions/domain/usecases/subscribe_to_fund_usecase.dart';
import 'package:btg_funds_app/features/transactions/domain/entities/transaction.dart';
import 'package:btg_funds_app/features/transactions/domain/entities/transaction_type.dart';
import 'package:btg_funds_app/features/user/domain/entities/notification_channel.dart';
import 'package:btg_funds_app/features/user/domain/entities/user_state.dart';

import '../../../../fixtures/fund_fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late MockGetFundByIdUseCase getFundById;
  late MockUserRepository userRepository;
  late MockSubscriptionRepository subscriptionRepository;
  late MockTransactionRepository transactionRepository;
  late MockAddTransactionUseCase addTransactionUseCase;
  late MockAtomicWrite atomicWrite;
  late MockUuid uuid;
  late SubscribeToFundUseCase useCase;

  final tClock = DateTime.utc(2026, 5, 12, 12);
  const tFund = FundFixtures.recaudadora; // id=1, min=75000
  const tUser = UserState(
    balance: 500000,
    email: 'usuario@btgpactual.co',
    phone: '+57 300 000 0000',
  );

  setUpAll(() {
    registerFallbackValue(NotificationChannel.email);
    registerFallbackValue(TransactionType.subscription);
    registerFallbackValue(<String, String>{});
  });

  setUp(() {
    getFundById = MockGetFundByIdUseCase();
    userRepository = MockUserRepository();
    subscriptionRepository = MockSubscriptionRepository();
    transactionRepository = MockTransactionRepository();
    addTransactionUseCase = MockAddTransactionUseCase();
    atomicWrite = MockAtomicWrite();
    uuid = MockUuid();
    when(() => uuid.v4()).thenReturn('sub_fixed');
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
        id: 'tx_fixed',
        type: TransactionType.subscription,
        fundId: tFund.id,
        fundName: tFund.name,
        amount: 100000,
        createdAt: tClock,
        channel: NotificationChannel.email,
      ),
    );

    useCase = SubscribeToFundUseCase(
      addTransactionUseCase: addTransactionUseCase,
      atomicWrite: atomicWrite,
      clock: () => tClock,
      getFundByIdUseCase: getFundById,
      subscriptionRepository: subscriptionRepository,
      transactionRepository: transactionRepository,
      uuid: uuid,
      userRepository: userRepository,
    );
  });

  void stubHappyPath({UserState user = tUser}) {
    when(() => getFundById(any())).thenAnswer((_) async => const Right(tFund));
    when(() => subscriptionRepository.getSubscriptions())
        .thenAnswer((_) async => const Right(<Subscription>[]));
    when(() => userRepository.getBalance())
        .thenAnswer((_) async => Right(user.balance));
    when(() => userRepository.getUser()).thenAnswer((_) async => Right(user));
    when(() => transactionRepository.getTransactions())
        .thenAnswer((_) async => const Right(<Transaction>[]));
    when(() => atomicWrite.commit(any())).thenAnswer((_) async {});
    when(
      () => userRepository.updateUser(
        preferredChannel: any(named: 'preferredChannel'),
      ),
    ).thenAnswer((_) async => Right(user));
  }

  group('SubscribeToFundUseCase', () {
    test('1. happy path → Right(Subscription)', () async {
      stubHappyPath();

      final result = await useCase(
        fundId: tFund.id,
        amount: 100000,
        channel: NotificationChannel.email,
      );

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Debió ser Right'),
        (sub) {
          expect(sub.id, equals('sub_fixed'));
          expect(sub.fundId, equals(tFund.id));
          expect(sub.amount, equals(100000));
          expect(sub.channel, equals(NotificationChannel.email));
        },
      );
      verify(() => atomicWrite.commit(any())).called(1);
    });

    test('2. fondo no existe → propaga BusinessFailure', () async {
      when(() => getFundById(any())).thenAnswer(
        (_) async => const Left(BusinessFailure('Fondo no disponible.')),
      );

      final result = await useCase(
        fundId: 'xyz',
        amount: 100000,
        channel: NotificationChannel.email,
      );

      result.fold(
        (failure) {
          expect(failure, isA<BusinessFailure>());
          expect(failure.message, equals('Fondo no disponible.'));
        },
        (_) => fail('Debió ser Left'),
      );
      verifyNever(() => atomicWrite.commit(any()));
    });

    test('3. ya tiene posición activa → BusinessFailure', () async {
      stubHappyPath();
      when(() => subscriptionRepository.getSubscriptions()).thenAnswer(
        (_) async => Right([
          Subscription(
            id: 'previa',
            fundId: tFund.id,
            fundName: tFund.name,
            amount: 100000,
            openedAt: tClock,
            channel: NotificationChannel.email,
          ),
        ]),
      );

      final result = await useCase(
        fundId: tFund.id,
        amount: 100000,
        channel: NotificationChannel.email,
      );

      result.fold(
        (failure) {
          expect(failure, isA<BusinessFailure>());
          expect(
            failure.message,
            contains('Ya tienes una participación activa'),
          );
          expect(failure.message, contains(tFund.name));
          expect(failure.message, contains('Cancélala primero.'));
        },
        (_) => fail('Debió ser Left'),
      );
    });

    test('4. monto < mínimo → BusinessFailure con monto formateado', () async {
      stubHappyPath();

      final result = await useCase(
        fundId: tFund.id,
        amount: 50000, // < 75000
        channel: NotificationChannel.email,
      );

      result.fold(
        (failure) {
          expect(failure, isA<BusinessFailure>());
          expect(
            failure.message,
            equals('El monto mínimo para ${tFund.name} es COP \$75.000.'),
          );
        },
        (_) => fail('Debió ser Left'),
      );
    });

    test('5. monto > saldo → BusinessFailure con saldo formateado', () async {
      stubHappyPath();

      final result = await useCase(
        fundId: tFund.id,
        amount: 600000, // > 500000
        channel: NotificationChannel.email,
      );

      result.fold(
        (failure) {
          expect(failure, isA<BusinessFailure>());
          expect(
            failure.message,
            equals('No tienes saldo suficiente. Disponible: COP \$500.000.'),
          );
        },
        (_) => fail('Debió ser Left'),
      );
    });

    test(
      '6. monto ≤ 0 → BusinessFailure ANTES de cualquier llamada async '
      'a subscriptions/balance/user',
      () async {
        stubHappyPath();

        final result = await useCase(
          fundId: tFund.id,
          amount: 0,
          channel: NotificationChannel.email,
        );

        result.fold(
          (failure) {
            expect(failure, isA<BusinessFailure>());
            expect(
              failure.message,
              equals('Ingresa un monto válido en pesos colombianos.'),
            );
          },
          (_) => fail('Debió ser Left'),
        );

        // Validación pura del input ocurre en posición 2 (después de fundo,
        // antes de async). Se debe haber consultado SOLO el fondo.
        verify(() => getFundById(any())).called(1);
        verifyNever(() => subscriptionRepository.getSubscriptions());
        verifyNever(() => userRepository.getBalance());
        verifyNever(() => userRepository.getUser());
        verifyNever(() => atomicWrite.commit(any()));
      },
    );

    test(
      '7. monto con decimales → BusinessFailure ANTES de cualquier '
      'llamada async a subscriptions/balance/user',
      () async {
        stubHappyPath();

        final result = await useCase(
          fundId: tFund.id,
          amount: 100000.50,
          channel: NotificationChannel.email,
        );

        result.fold(
          (failure) {
            expect(failure, isA<BusinessFailure>());
            expect(
              failure.message,
              equals('Ingresa un monto válido en pesos colombianos.'),
            );
          },
          (_) => fail('Debió ser Left'),
        );

        verify(() => getFundById(any())).called(1);
        verifyNever(() => subscriptionRepository.getSubscriptions());
        verifyNever(() => userRepository.getBalance());
        verifyNever(() => userRepository.getUser());
        verifyNever(() => atomicWrite.commit(any()));
      },
    );

    test(
      '8. canal=email + email inválido en usuario → BusinessFailure',
      () async {
        stubHappyPath(user: tUser.copyWith(email: 'sin-arroba'));

        final result = await useCase(
          fundId: tFund.id,
          amount: 100000,
          channel: NotificationChannel.email,
        );

        result.fold(
          (failure) {
            expect(failure, isA<BusinessFailure>());
            expect(
              failure.message,
              equals(
                'Necesitamos un correo válido para enviarte la confirmación.',
              ),
            );
          },
          (_) => fail('Debió ser Left'),
        );

        // Variante SMS con teléfono vacío.
        stubHappyPath(user: tUser.copyWith(phone: ''));

        final resultSms = await useCase(
          fundId: tFund.id,
          amount: 100000,
          channel: NotificationChannel.sms,
        );

        resultSms.fold(
          (failure) {
            expect(failure, isA<BusinessFailure>());
            expect(
              failure.message,
              equals('Necesitamos tu teléfono para enviarte el SMS.'),
            );
          },
          (_) => fail('Debió ser Left'),
        );
      },
    );

    test('CacheException de AtomicWrite → Left(CacheFailure)', () async {
      stubHappyPath();
      when(() => atomicWrite.commit(any()))
          .thenThrow(const CacheException('Disco lleno'));

      final result = await useCase(
        fundId: tFund.id,
        amount: 100000,
        channel: NotificationChannel.email,
      );

      result.fold(
        (failure) {
          expect(failure, isA<CacheFailure>());
          expect(failure.message, equals('Disco lleno'));
        },
        (_) => fail('Debió ser Left'),
      );
    });
  });
}
