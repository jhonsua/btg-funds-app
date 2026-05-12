import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:btg_funds_app/features/subscriptions/domain/entities/subscription.dart';

part 'subscription_state.freezed.dart';

@freezed
sealed class SubscriptionState with _$SubscriptionState {
  const factory SubscriptionState.idle() = SubscriptionIdle;
  const factory SubscriptionState.loading() = SubscriptionLoading;
  const factory SubscriptionState.success(Subscription subscription) =
      SubscriptionSuccess;
  const factory SubscriptionState.cancelled() = SubscriptionCancelled;
  const factory SubscriptionState.error(String message) = SubscriptionError;
}
