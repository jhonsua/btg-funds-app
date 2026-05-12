import 'package:dartz/dartz.dart';

import 'package:btg_funds_app/core/errors/failure.dart';
import 'package:btg_funds_app/features/transactions/domain/entities/transaction.dart';
import 'package:btg_funds_app/features/transactions/domain/entities/transaction_filter.dart';
import 'package:btg_funds_app/features/transactions/domain/repositories/transaction_repository.dart';

/// Retorna la lista de transacciones del repo, filtrada por el [TransactionFilter]
/// si se provee, y siempre ordenada **cronológicamente descendente** por
/// `createdAt` (más reciente primero).
///
/// El desempate cuando dos transacciones comparten exactamente el mismo
/// `createdAt` (posible si subscribe/cancel se ejecutan en el mismo
/// milisegundo, o si los tests usan clock fijo) se hace por `id` descendente.
/// Los IDs son UUID v4, lo cual da un orden estable y determinístico sin
/// favorecer una operación sobre otra por su tipo.
class GetTransactionsUseCase {
  GetTransactionsUseCase(this._repository);

  final TransactionRepository _repository;

  Future<Either<Failure, List<Transaction>>> call([
    TransactionFilter? filter,
  ]) async {
    final result = await _repository.getTransactions();
    return result.map((txs) {
      final filtered = filter == null || filter.isEmpty
          ? List<Transaction>.from(txs)
          : txs.where((tx) => _matches(filter, tx)).toList();
      filtered.sort((a, b) {
        final dateCompare = b.createdAt.compareTo(a.createdAt);
        if (dateCompare != 0) return dateCompare;
        return b.id.compareTo(a.id);
      });
      return filtered;
    });
  }

  bool _matches(TransactionFilter filter, Transaction tx) {
    if (filter.type != null && tx.type != filter.type) return false;
    if (filter.fundId != null && tx.fundId != filter.fundId) return false;
    if (filter.dateRange != null && !filter.dateRange!.contains(tx.createdAt)) {
      return false;
    }
    return true;
  }
}
