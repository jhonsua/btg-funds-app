import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:btg_funds_app/core/constants/app_constants.dart';
import 'package:btg_funds_app/core/errors/exceptions.dart';
import 'package:btg_funds_app/core/errors/failure.dart';
import 'package:btg_funds_app/core/storage/storage_keys.dart';
import 'package:btg_funds_app/features/user/domain/entities/notification_channel.dart';
import 'package:btg_funds_app/features/user/domain/entities/user_state.dart';
import 'package:btg_funds_app/features/user/domain/usecases/reset_demo_usecase.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockAtomicWrite atomicWrite;
  late MockUserRepository userRepository;
  late ResetDemoUseCase useCase;

  const tFreshUser = UserState(
    balance: kInitialBalance,
    email: 'usuario@btgpactual.co',
    phone: '+57 300 000 0000',
    preferredChannel: NotificationChannel.email,
  );

  setUpAll(() {
    registerFallbackValue(NotificationChannel.email);
    registerFallbackValue(<String, String>{});
  });

  setUp(() {
    atomicWrite = MockAtomicWrite();
    userRepository = MockUserRepository();
    useCase = ResetDemoUseCase(
      atomicWrite: atomicWrite,
      userRepository: userRepository,
    );
  });

  group('ResetDemoUseCase', () {
    // NOTA Etapa 4: agregar test "bloqueado por operación pendiente" cuando
    // existan SubscriptionNotifier/TransactionsNotifier y se inyecte el lock
    // (ver TODO en reset_demo_usecase.dart y SPEC_FUNCIONAL §7).

    test(
      'happy path → AtomicWrite.commit recibe las 3 keys con balance inicial '
      'y listas vacías; retorna Right con el UserState fresco',
      () async {
        Map<String, String>? capturedWrites;
        when(() => atomicWrite.commit(any())).thenAnswer((invocation) async {
          capturedWrites =
              invocation.positionalArguments.first as Map<String, String>;
        });
        when(() => userRepository.getUser())
            .thenAnswer((_) async => const Right(tFreshUser));

        final result = await useCase();

        expect(
          result,
          equals(const Right<Failure, UserState>(tFreshUser)),
        );
        expect(capturedWrites, isNotNull);
        expect(
          capturedWrites!.keys,
          containsAll(<String>[
            StorageKeys.userBalance,
            StorageKeys.userSubscriptions,
            StorageKeys.userTransactions,
          ]),
        );
        final balance = double.parse(capturedWrites![StorageKeys.userBalance]!);
        expect(balance, equals(kInitialBalance));
        final subs = jsonDecode(capturedWrites![StorageKeys.userSubscriptions]!)
            as List<dynamic>;
        expect(subs, isEmpty);
        final txs = jsonDecode(capturedWrites![StorageKeys.userTransactions]!)
            as List<dynamic>;
        expect(txs, isEmpty);
      },
    );

    test(
      'reset NO modifica email/phone/preferredChannel (NO se llaman setters '
      'del perfil ni se incluyen esas keys en el commit)',
      () async {
        Map<String, String>? capturedWrites;
        when(() => atomicWrite.commit(any())).thenAnswer((invocation) async {
          capturedWrites =
              invocation.positionalArguments.first as Map<String, String>;
        });
        when(() => userRepository.getUser())
            .thenAnswer((_) async => const Right(tFreshUser));

        await useCase();

        // Las 3 keys del perfil NUNCA aparecen en el commit atómico.
        expect(capturedWrites!.containsKey(StorageKeys.userEmail), isFalse);
        expect(capturedWrites!.containsKey(StorageKeys.userPhone), isFalse);
        expect(capturedWrites!.containsKey(StorageKeys.userChannel), isFalse);
        // Tampoco se invoca updateUser (el use case no debe tocar perfil).
        verifyNever(
          () => userRepository.updateUser(
            email: any(named: 'email'),
            phone: any(named: 'phone'),
            preferredChannel: any(named: 'preferredChannel'),
          ),
        );
      },
    );

    test('AtomicWrite lanza CacheException → Left(CacheFailure)', () async {
      when(() => atomicWrite.commit(any())).thenThrow(
        const CacheException('Falló commit atómico'),
      );

      final result = await useCase();

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<CacheFailure>());
          expect(failure.message, equals('Falló commit atómico'));
        },
        (_) => fail('Debió retornar Left'),
      );
      // userRepository.getUser NO debe llamarse si el commit falló.
      verifyNever(() => userRepository.getUser());
    });

    test(
      'getUser falla después del commit exitoso → Left propagado',
      () async {
        when(() => atomicWrite.commit(any())).thenAnswer((_) async {});
        when(() => userRepository.getUser()).thenAnswer(
          (_) async =>
              const Left(CacheFailure('No se pudo leer el usuario tras reset')),
        );

        final result = await useCase();

        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) {
            expect(failure, isA<CacheFailure>());
            expect(
              failure.message,
              equals('No se pudo leer el usuario tras reset'),
            );
          },
          (_) => fail('Debió retornar Left'),
        );
      },
    );
  });
}
