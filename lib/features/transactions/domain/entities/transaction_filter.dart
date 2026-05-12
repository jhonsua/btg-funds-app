import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:btg_funds_app/features/transactions/domain/entities/date_range.dart';
import 'package:btg_funds_app/features/transactions/domain/entities/transaction_type.dart';

part 'transaction_filter.freezed.dart';

@freezed
class TransactionFilter with _$TransactionFilter {
  const TransactionFilter._();

  const factory TransactionFilter({
    TransactionType? type,
    String? fundId,
    DateRange? dateRange,
  }) = _TransactionFilter;

  /// API ergonómica: comunica "sin filtro" explícitamente. Equivalente
  /// a `const TransactionFilter()`.
  factory TransactionFilter.empty() => const TransactionFilter();

  bool get isEmpty => type == null && fundId == null && dateRange == null;
}
