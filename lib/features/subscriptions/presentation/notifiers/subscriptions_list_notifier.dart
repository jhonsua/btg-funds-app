import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:btg_funds_app/features/subscriptions/domain/entities/subscription.dart';
import 'package:btg_funds_app/features/subscriptions/presentation/providers/providers.dart';

class SubscriptionsListNotifier extends AsyncNotifier<List<Subscription>> {
  String? lastError;

  void _setError(String message) {
    lastError = message;
  }

  @override
  Future<List<Subscription>> build() async {
    final result = await ref.read(getSubscriptionsUseCaseProvider).call();
    return result.fold(
      (failure) {
        _setError(failure.message);
        throw failure;
      },
      (subs) {
        lastError = null;
        return subs;
      },
    );
  }
}
