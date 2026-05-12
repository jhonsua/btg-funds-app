import 'package:btg_funds_app/core/errors/exceptions.dart';
import 'package:btg_funds_app/features/transactions/domain/entities/transaction.dart';
import 'package:btg_funds_app/features/transactions/domain/entities/transaction_type.dart';
import 'package:btg_funds_app/features/user/domain/entities/notification_channel.dart';

class TransactionModel {
  const TransactionModel({
    required this.id,
    required this.type,
    required this.fundId,
    required this.fundName,
    required this.amount,
    required this.createdAt,
    this.channel,
  });

  final String id;
  final TransactionType type;
  final String fundId;
  final String fundName;
  final double amount;
  final DateTime createdAt;
  final NotificationChannel? channel;

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String?;
    if (id == null || id.isEmpty) {
      throw const ServerException('Transaction.id requerido.');
    }
    final typeName = json['type'] as String?;
    if (typeName == null) {
      throw const ServerException('Transaction.type requerido.');
    }
    final type = TransactionType.values.firstWhere(
      (t) => t.name == typeName,
      orElse: () => throw ServerException(
        'Transaction.type desconocido: $typeName',
      ),
    );
    final rawAmount = json['amount'];
    if (rawAmount is! num) {
      throw const ServerException(
        'Transaction.amount requerido y numérico.',
      );
    }
    final createdAtRaw = json['createdAt'] as String?;
    if (createdAtRaw == null) {
      throw const ServerException('Transaction.createdAt requerido.');
    }
    return TransactionModel(
      id: id,
      type: type,
      fundId: (json['fundId'] as String?) ?? '',
      fundName: (json['fundName'] as String?) ?? '',
      amount: rawAmount.toDouble(),
      createdAt: DateTime.parse(createdAtRaw),
      channel: _channelFromName(json['channel'] as String?),
    );
  }

  factory TransactionModel.fromEntity(Transaction tx) => TransactionModel(
        id: tx.id,
        type: tx.type,
        fundId: tx.fundId,
        fundName: tx.fundName,
        amount: tx.amount,
        createdAt: tx.createdAt,
        channel: tx.channel,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'type': type.name,
        'fundId': fundId,
        'fundName': fundName,
        'amount': amount,
        'createdAt': createdAt.toIso8601String(),
        if (channel != null) 'channel': channel!.name,
      };

  Transaction toEntity() => Transaction(
        id: id,
        type: type,
        fundId: fundId,
        fundName: fundName,
        amount: amount,
        createdAt: createdAt,
        channel: channel,
      );

  static NotificationChannel? _channelFromName(String? name) {
    if (name == null || name.isEmpty) return null;
    try {
      return NotificationChannel.values.byName(name);
    } catch (_) {
      return null;
    }
  }
}
