import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:btg_funds_app/core/errors/failure.dart';
import 'package:btg_funds_app/features/transactions/domain/entities/transaction.dart';
import 'package:btg_funds_app/features/transactions/domain/entities/transaction_filter.dart';
import 'package:btg_funds_app/features/transactions/domain/entities/transaction_type.dart';
import 'package:btg_funds_app/features/transactions/presentation/providers/providers.dart';

import '../../../../helpers/mocks.dart';

class _FakeFilter extends Fake implements TransactionFilter {}

void main() {
  late MockGetTransactionsUseCase getTransactions;
  late ProviderContainer container;

  final tTx = Transaction(
    id: 'tx_1',
    type: TransactionType.subscription,
    fundId: 'f1',
    fundName: 'Fondo X',
    amount: 100000,
    createdAt: DateTime.utc(2026, 5, 12),
  );

  setUpAll(() {
    registerFallbackValue(_FakeFilter());
  });

  setUp(() {
    getTransactions = MockGetTransactionsUseCase();
    when(
      () => getTransactions(any()),
    ).thenAnswer((_) async => Right([tTx]));
    container = ProviderContainer(
      overrides: [
        getTransactionsUseCaseProvider.overrideWithValue(getTransactions),
      ],
    );
    addTearDown(container.dispose);
  });

  group('TransactionsNotifier', () {
    test('build inicial → AsyncData con la lista del repo', () async {
      final txs = await container.read(transactionsNotifierProvider.future);

      expect(txs, equals([tTx]));
      expect(
        container.read(transactionsNotifierProvider.notifier).lastError,
        isNull,
      );
    });

    test(
      'applyFilter actualiza currentFilter y refresca la lista',
      () async {
        await container.read(transactionsNotifierProvider.future);
        when(
          () => getTransactions(any()),
        ).thenAnswer((_) async => const Right(<Transaction>[]));

        final notifier = container.read(transactionsNotifierProvider.notifier);
        const filter = TransactionFilter(type: TransactionType.subscription);
        await notifier.applyFilter(filter);

        expect(notifier.currentFilter, equals(filter));
        expect(
          container.read(transactionsNotifierProvider).valueOrNull,
          isEmpty,
        );
      },
    );

    test('clearFilter resetea a TransactionFilter.empty', () async {
      await container.read(transactionsNotifierProvider.future);
      final notifier = container.read(transactionsNotifierProvider.notifier);
      await notifier.applyFilter(
        const TransactionFilter(type: TransactionType.cancellation),
      );

      await notifier.clearFilter();

      expect(notifier.currentFilter.isEmpty, isTrue);
    });

    test(
      'refresh re-ejecuta sin cambiar el filtro actual',
      () async {
        await container.read(transactionsNotifierProvider.future);
        final notifier = container.read(transactionsNotifierProvider.notifier);
        await notifier.applyFilter(
          const TransactionFilter(fundId: 'f1'),
        );
        final before = notifier.currentFilter;

        await notifier.refresh();

        // El filtro no cambió tras refresh.
        expect(notifier.currentFilter, equals(before));
        // El use case fue invocado al menos 3 veces (build inicial,
        // applyFilter, refresh).
        verify(() => getTransactions(any())).called(greaterThanOrEqualTo(3));
      },
    );

    test(
      'error en getTransactions propaga AsyncError + setea lastError',
      () async {
        when(
          () => getTransactions(any()),
        ).thenAnswer((_) async => const Left(CacheFailure('Disco lleno')));

        try {
          await container.read(transactionsNotifierProvider.future);
        } on Failure {
          // esperado
        }

        expect(
          container.read(transactionsNotifierProvider).hasError,
          isTrue,
        );
        expect(
          container.read(transactionsNotifierProvider.notifier).lastError,
          equals('Disco lleno'),
        );
      },
    );
  });
}
