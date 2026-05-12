import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:btg_funds_app/features/transactions/domain/entities/date_range.dart';
import 'package:btg_funds_app/features/transactions/domain/entities/transaction.dart';
import 'package:btg_funds_app/features/transactions/domain/entities/transaction_filter.dart';
import 'package:btg_funds_app/features/transactions/domain/entities/transaction_type.dart';
import 'package:btg_funds_app/features/transactions/domain/usecases/get_transactions_usecase.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockTransactionRepository repository;
  late GetTransactionsUseCase useCase;

  // 4 transacciones con timestamps fuera de orden y mezcla de tipos/fondos.
  final tMay01 = Transaction(
    id: 'tx_old',
    type: TransactionType.subscription,
    fundId: 'f1',
    fundName: 'Fondo X',
    amount: 100000,
    createdAt: DateTime.utc(2026, 5, 1, 10),
  );
  final tMay05 = Transaction(
    id: 'tx_mid_a',
    type: TransactionType.cancellation,
    fundId: 'f1',
    fundName: 'Fondo X',
    amount: 100000,
    createdAt: DateTime.utc(2026, 5, 5, 12),
  );
  final tMay10 = Transaction(
    id: 'tx_mid_b',
    type: TransactionType.subscription,
    fundId: 'f2',
    fundName: 'Fondo Y',
    amount: 200000,
    createdAt: DateTime.utc(2026, 5, 10, 8),
  );
  final tMay12 = Transaction(
    id: 'tx_new',
    type: TransactionType.subscription,
    fundId: 'f1',
    fundName: 'Fondo X',
    amount: 50000,
    createdAt: DateTime.utc(2026, 5, 12, 23, 59),
  );

  final fullCatalog = [tMay05, tMay12, tMay01, tMay10]; // fuera de orden

  setUp(() {
    repository = MockTransactionRepository();
    useCase = GetTransactionsUseCase(repository);
    when(
      () => repository.getTransactions(),
    ).thenAnswer((_) async => Right(fullCatalog));
  });

  group('GetTransactionsUseCase — sin filtro', () {
    test(
      '1. filtro null retorna todo ordenado descendente por createdAt',
      () async {
        final result = await useCase();

        result.fold((_) => fail('Debió ser Right'), (txs) {
          expect(txs.length, equals(4));
          expect(txs[0].id, equals('tx_new'));
          expect(txs[1].id, equals('tx_mid_b'));
          expect(txs[2].id, equals('tx_mid_a'));
          expect(txs[3].id, equals('tx_old'));
        });
      },
    );
  });

  group('GetTransactionsUseCase — filtros simples', () {
    test('2. filtro por tipo=subscription retorna sólo subscriptions',
        () async {
      final result = await useCase(
        const TransactionFilter(type: TransactionType.subscription),
      );

      result.fold((_) => fail('Debió ser Right'), (txs) {
        expect(txs.length, equals(3));
        expect(
          txs.every((t) => t.type == TransactionType.subscription),
          isTrue,
        );
        expect(txs.first.id, equals('tx_new')); // ordenadas desc
      });
    });

    test('3. filtro por tipo=cancellation retorna sólo cancellations',
        () async {
      final result = await useCase(
        const TransactionFilter(type: TransactionType.cancellation),
      );

      result.fold((_) => fail('Debió ser Right'), (txs) {
        expect(txs.length, equals(1));
        expect(txs.first.id, equals('tx_mid_a'));
      });
    });

    test('4. filtro por fundId retorna sólo transacciones de ese fondo',
        () async {
      final result = await useCase(const TransactionFilter(fundId: 'f1'));

      result.fold((_) => fail('Debió ser Right'), (txs) {
        expect(txs.length, equals(3));
        expect(txs.every((t) => t.fundId == 'f1'), isTrue);
      });
    });

    test(
      '5. filtro por dateRange retorna sólo transacciones dentro del rango',
      () async {
        final result = await useCase(
          TransactionFilter(
            dateRange: DateRange(
              start: DateTime.utc(2026, 5, 4),
              end: DateTime.utc(2026, 5, 11),
            ),
          ),
        );

        result.fold((_) => fail('Debió ser Right'), (txs) {
          expect(txs.length, equals(2));
          expect(
            txs.map((t) => t.id).toList(),
            equals(['tx_mid_b', 'tx_mid_a']),
          );
        });
      },
    );

    test('6. filtro por dateRange sin coincidencias retorna lista vacía',
        () async {
      final result = await useCase(
        TransactionFilter(
          dateRange: DateRange(
            start: DateTime.utc(2030),
            end: DateTime.utc(2030, 12, 31),
          ),
        ),
      );

      result.fold(
        (_) => fail('Debió ser Right'),
        (txs) => expect(txs, isEmpty),
      );
    });
  });

  group('GetTransactionsUseCase — combinaciones', () {
    test('7. tipo + fondo: sólo subscriptions del fondo f1', () async {
      final result = await useCase(
        const TransactionFilter(
          type: TransactionType.subscription,
          fundId: 'f1',
        ),
      );

      result.fold((_) => fail('Debió ser Right'), (txs) {
        expect(txs.length, equals(2));
        expect(txs.map((t) => t.id).toList(), equals(['tx_new', 'tx_old']));
      });
    });

    test('8. tipo + fondo + dateRange: combinación completa', () async {
      final result = await useCase(
        TransactionFilter(
          type: TransactionType.subscription,
          fundId: 'f1',
          dateRange: DateRange(
            start: DateTime.utc(2026, 5, 11),
            end: DateTime.utc(2026, 5, 12, 23, 59),
          ),
        ),
      );

      result.fold((_) => fail('Debió ser Right'), (txs) {
        expect(txs.length, equals(1));
        expect(txs.first.id, equals('tx_new'));
      });
    });
  });

  group('GetTransactionsUseCase — sort determinístico', () {
    test(
      '9. dos transacciones con MISMO createdAt: desempate por id descendente',
      () async {
        // Mismo timestamp exacto, IDs distintos para verificar desempate.
        final tSameTimeA = Transaction(
          id: 'aaa', // alfabéticamente menor
          type: TransactionType.subscription,
          fundId: 'f1',
          fundName: 'Fondo X',
          amount: 100000,
          createdAt: DateTime.utc(2026, 5, 12, 12),
        );
        final tSameTimeB = Transaction(
          id: 'zzz', // alfabéticamente mayor
          type: TransactionType.cancellation,
          fundId: 'f1',
          fundName: 'Fondo X',
          amount: 100000,
          createdAt: DateTime.utc(2026, 5, 12, 12), // EXACTAMENTE igual
        );
        when(
          () => repository.getTransactions(),
        ).thenAnswer((_) async => Right([tSameTimeA, tSameTimeB]));

        final result = await useCase();

        result.fold((_) => fail('Debió ser Right'), (txs) {
          expect(txs.length, equals(2));
          // El id mayor (zzz) va primero por el desempate descendente.
          expect(txs[0].id, equals('zzz'));
          expect(txs[1].id, equals('aaa'));
        });
      },
    );
  });
}
