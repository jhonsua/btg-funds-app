import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:btg_funds_app/features/transactions/domain/entities/transaction_type.dart';
import 'package:btg_funds_app/features/user/domain/entities/notification_channel.dart';

part 'transaction.freezed.dart';

@freezed
class Transaction with _$Transaction {
  const factory Transaction({
    required String id,
    required TransactionType type,
    required String fundId,
    required String fundName,
    required double amount,
    required DateTime createdAt,
    NotificationChannel? channel,
  }) = _Transaction;
}
