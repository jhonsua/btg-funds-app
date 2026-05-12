import 'package:btg_funds_app/core/errors/exceptions.dart';
import 'package:btg_funds_app/features/subscriptions/domain/entities/subscription.dart';
import 'package:btg_funds_app/features/user/domain/entities/notification_channel.dart';

class SubscriptionModel {
  const SubscriptionModel({
    required this.id,
    required this.fundId,
    required this.fundName,
    required this.amount,
    required this.openedAt,
    required this.channel,
  });

  final String id;
  final String fundId;
  final String fundName;
  final double amount;
  final DateTime openedAt;
  final NotificationChannel channel;

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String?;
    if (id == null || id.isEmpty) {
      throw const CacheException('Subscription.id requerido.');
    }
    final fundId = json['fundId'] as String?;
    if (fundId == null || fundId.isEmpty) {
      throw const CacheException('Subscription.fundId requerido.');
    }
    final rawAmount = json['amount'];
    if (rawAmount is! num) {
      throw const CacheException(
        'Subscription.amount requerido y numérico.',
      );
    }
    final openedAtRaw = json['openedAt'] as String?;
    if (openedAtRaw == null) {
      throw const CacheException('Subscription.openedAt requerido.');
    }
    final channelName = json['channel'] as String?;
    if (channelName == null) {
      throw const CacheException('Subscription.channel requerido.');
    }
    final NotificationChannel channel;
    try {
      channel = NotificationChannel.values.byName(channelName);
    } catch (_) {
      throw CacheException(
        'Subscription.channel desconocido: $channelName',
      );
    }
    return SubscriptionModel(
      id: id,
      fundId: fundId,
      fundName: (json['fundName'] as String?) ?? '',
      amount: rawAmount.toDouble(),
      openedAt: DateTime.parse(openedAtRaw),
      channel: channel,
    );
  }

  factory SubscriptionModel.fromEntity(Subscription sub) => SubscriptionModel(
        id: sub.id,
        fundId: sub.fundId,
        fundName: sub.fundName,
        amount: sub.amount,
        openedAt: sub.openedAt,
        channel: sub.channel,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'fundId': fundId,
        'fundName': fundName,
        'amount': amount,
        'openedAt': openedAt.toIso8601String(),
        'channel': channel.name,
      };

  Subscription toEntity() => Subscription(
        id: id,
        fundId: fundId,
        fundName: fundName,
        amount: amount,
        openedAt: openedAt,
        channel: channel,
      );
}
