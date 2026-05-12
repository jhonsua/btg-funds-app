import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:btg_funds_app/features/transactions/data/datasources/shared_prefs_transaction_datasource.dart';
import 'package:btg_funds_app/features/transactions/data/models/transaction_model.dart';
import 'package:btg_funds_app/features/transactions/domain/entities/transaction_type.dart';

void main() {
  late SharedPreferences prefs;
  late SharedPrefsTransactionDatasource datasource;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    datasource = SharedPrefsTransactionDatasource(prefs);
  });

  group('SharedPrefsTransactionDatasource', () {
    test('cold start retorna lista vacía sin lanzar', () async {
      final txs = await datasource.getTransactions();
      expect(txs, isEmpty);
    });

    test('addTransaction persiste y getTransactions la devuelve', () async {
      final tx = TransactionModel(
        id: 'tx_1',
        type: TransactionType.subscription,
        fundId: 'f1',
        fundName: 'Fondo X',
        amount: 100000,
        createdAt: DateTime.utc(2026, 5, 12),
      );

      await datasource.addTransaction(tx);
      final txs = await datasource.getTransactions();

      expect(txs.length, equals(1));
      expect(txs.first.id, equals('tx_1'));
      expect(txs.first.type, equals(TransactionType.subscription));
    });
  });
}
