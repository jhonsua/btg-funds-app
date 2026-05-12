import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:btg_funds_app/features/subscriptions/presentation/notifiers/subscription_state.dart';
import 'package:btg_funds_app/features/subscriptions/presentation/providers/providers.dart';
import 'package:btg_funds_app/features/user/domain/entities/notification_channel.dart';
import 'package:btg_funds_app/features/user/presentation/providers/providers.dart';

class SubscriptionNotifier extends Notifier<SubscriptionState> {
  String? lastError;

  void _setError(String message) {
    lastError = message;
  }

  @override
  SubscriptionState build() => const SubscriptionState.idle();

  Future<bool> subscribe({
    required String fundId,
    required double amount,
    required NotificationChannel channel,
  }) async {
    state = const SubscriptionState.loading();
    final result = await ref.read(subscribeToFundUseCaseProvider).call(
          fundId: fundId,
          amount: amount,
          channel: channel,
        );
    return result.fold(
      (failure) {
        _setError(failure.message);
        state = SubscriptionState.error(failure.message);
        return false;
      },
      (subscription) {
        lastError = null;
        state = SubscriptionState.success(subscription);
        ref.invalidate(userNotifierProvider);
        ref.invalidate(subscriptionsListNotifierProvider);
        // TODO Etapa 5: invalidar transactionsNotifierProvider cuando exista.
        return true;
      },
    );
  }

  Future<bool> cancel({required String subscriptionId}) async {
    state = const SubscriptionState.loading();
    final result = await ref
        .read(cancelSubscriptionUseCaseProvider)
        .call(subscriptionId: subscriptionId);
    return result.fold(
      (failure) {
        _setError(failure.message);
        state = SubscriptionState.error(failure.message);
        return false;
      },
      (_) {
        lastError = null;
        state = const SubscriptionState.cancelled();
        ref.invalidate(userNotifierProvider);
        ref.invalidate(subscriptionsListNotifierProvider);
        // TODO Etapa 5: invalidar transactionsNotifierProvider cuando exista.
        return true;
      },
    );
  }
}
