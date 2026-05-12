import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:btg_funds_app/core/clock.dart';
import 'package:btg_funds_app/core/uuid_provider.dart';
import 'package:btg_funds_app/features/transactions/data/datasources/local_transaction_datasource.dart';
import 'package:btg_funds_app/features/transactions/data/datasources/shared_prefs_transaction_datasource.dart';
import 'package:btg_funds_app/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:btg_funds_app/features/transactions/domain/entities/transaction.dart';
import 'package:btg_funds_app/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:btg_funds_app/features/transactions/domain/usecases/add_transaction_usecase.dart';
import 'package:btg_funds_app/features/transactions/domain/usecases/get_transactions_usecase.dart';
import 'package:btg_funds_app/features/transactions/presentation/notifiers/transactions_notifier.dart';
import 'package:btg_funds_app/features/user/presentation/providers/providers.dart';

final localTransactionDatasourceProvider =
    Provider<LocalTransactionDatasource>((ref) {
  return SharedPrefsTransactionDatasource(
    ref.watch(sharedPreferencesProvider),
  );
});

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepositoryImpl(
    ref.watch(localTransactionDatasourceProvider),
  );
});

final addTransactionUseCaseProvider = Provider<AddTransactionUseCase>((ref) {
  return AddTransactionUseCase(
    repository: ref.watch(transactionRepositoryProvider),
    uuid: ref.watch(uuidProvider),
    clock: ref.watch(clockProvider),
  );
});

final getTransactionsUseCaseProvider = Provider<GetTransactionsUseCase>((ref) {
  return GetTransactionsUseCase(ref.watch(transactionRepositoryProvider));
});

final transactionsNotifierProvider =
    AsyncNotifierProvider<TransactionsNotifier, List<Transaction>>(
  TransactionsNotifier.new,
);
