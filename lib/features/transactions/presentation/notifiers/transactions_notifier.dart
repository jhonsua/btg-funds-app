import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:btg_funds_app/features/transactions/domain/entities/transaction.dart';
import 'package:btg_funds_app/features/transactions/domain/entities/transaction_filter.dart';
import 'package:btg_funds_app/features/transactions/presentation/providers/providers.dart';

class TransactionsNotifier extends AsyncNotifier<List<Transaction>> {
  TransactionFilter _currentFilter = TransactionFilter.empty();
  String? lastError;

  TransactionFilter get currentFilter => _currentFilter;

  void _setError(String message) {
    lastError = message;
  }

  @override
  Future<List<Transaction>> build() async {
    final result =
        await ref.read(getTransactionsUseCaseProvider).call(_currentFilter);
    return result.fold(
      (failure) {
        _setError(failure.message);
        throw failure;
      },
      (txs) {
        lastError = null;
        return txs;
      },
    );
  }

  /// Aplica un nuevo filtro y vuelve a cargar la lista.
  Future<void> applyFilter(TransactionFilter filter) async {
    _currentFilter = filter;
    state = const AsyncLoading<List<Transaction>>();
    state = await AsyncValue.guard(build);
  }

  /// Resetea a "sin filtro" y recarga.
  Future<void> clearFilter() => applyFilter(TransactionFilter.empty());

  /// Recarga la lista manteniendo el filtro actual (entry point del
  /// pull-to-refresh de Etapa 6).
  Future<void> refresh() async {
    state = const AsyncLoading<List<Transaction>>();
    state = await AsyncValue.guard(build);
  }
}
