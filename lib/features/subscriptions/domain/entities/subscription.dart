import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:btg_funds_app/features/user/domain/entities/notification_channel.dart';

part 'subscription.freezed.dart';

@freezed
class Subscription with _$Subscription {
  const factory Subscription({
    required String id,
    required String fundId,
    // Denormalizado para evitar joins al renderizar listas.
    required String fundName,
    required double amount,
    required DateTime openedAt,
    required NotificationChannel channel,
  }) = _Subscription;
}
