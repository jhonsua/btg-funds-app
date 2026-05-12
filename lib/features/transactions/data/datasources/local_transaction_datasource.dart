import 'package:btg_funds_app/features/transactions/data/models/transaction_model.dart';

abstract class LocalTransactionDatasource {
  Future<List<TransactionModel>> getTransactions();
  Future<void> addTransaction(TransactionModel model);
}
