import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:btg_funds_app/core/errors/failure.dart';
import 'package:btg_funds_app/features/funds/domain/entities/fund.dart';
import 'package:btg_funds_app/features/funds/presentation/providers/providers.dart';

import '../../../../fixtures/fund_fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late MockGetFundsUseCase getFunds;
  late ProviderContainer container;

  setUp(() {
    getFunds = MockGetFundsUseCase();
    container = ProviderContainer(
      overrides: [getFundsUseCaseProvider.overrideWithValue(getFunds)],
    );
    addTearDown(container.dispose);
  });

  group('FundsNotifier', () {
    test('build() carga los fondos y deja state en AsyncData', () async {
      when(() => getFunds())
          .thenAnswer((_) async => const Right(FundFixtures.all));

      final funds = await container.read(fundsNotifierProvider.future);

      expect(funds.length, equals(5));
      expect(
        container.read(fundsNotifierProvider).valueOrNull,
        isA<List<Fund>>(),
      );
      expect(
        container.read(fundsNotifierProvider.notifier).lastError,
        isNull,
      );
    });

    test('build() en error setea lastError y state queda AsyncError', () async {
      when(() => getFunds()).thenAnswer(
        (_) async => const Left(ServerFailure('Backend off')),
      );

      try {
        await container.read(fundsNotifierProvider.future);
      } on Failure {
        // esperado
      }

      expect(container.read(fundsNotifierProvider).hasError, isTrue);
      expect(
        container.read(fundsNotifierProvider.notifier).lastError,
        equals('Backend off'),
      );
    });

    test('refresh() re-invoca el use case y actualiza el estado', () async {
      when(() => getFunds()).thenAnswer((_) async => const Right(<Fund>[]));
      await container.read(fundsNotifierProvider.future);

      when(() => getFunds())
          .thenAnswer((_) async => const Right(FundFixtures.all));

      await container.read(fundsNotifierProvider.notifier).refresh();

      expect(
        container.read(fundsNotifierProvider).valueOrNull?.length,
        equals(5),
      );
    });
  });
}
