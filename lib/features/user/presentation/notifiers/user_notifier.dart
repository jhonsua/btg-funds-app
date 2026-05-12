import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:btg_funds_app/features/user/domain/entities/notification_channel.dart';
import 'package:btg_funds_app/features/user/domain/entities/user_state.dart';
import 'package:btg_funds_app/features/user/presentation/providers/providers.dart';

class UserNotifier extends AsyncNotifier<UserState> {
  String? lastError;

  void _setError(String message) {
    lastError = message;
  }

  @override
  Future<UserState> build() async {
    final result = await ref.read(getUserUseCaseProvider).call();
    return result.fold(
      (failure) {
        _setError(failure.message);
        throw failure;
      },
      (user) {
        lastError = null;
        return user;
      },
    );
  }

  Future<bool> updateProfile({
    String? email,
    String? phone,
    NotificationChannel? preferredChannel,
  }) async {
    state = const AsyncLoading<UserState>();
    final result = await ref.read(updateUserUseCaseProvider).call(
          email: email,
          phone: phone,
          preferredChannel: preferredChannel,
        );
    return result.fold(
      (failure) {
        _setError(failure.message);
        state = AsyncError<UserState>(failure, StackTrace.current);
        return false;
      },
      (updated) {
        lastError = null;
        state = AsyncData<UserState>(updated);
        return true;
      },
    );
  }

  Future<bool> resetDemo() async {
    state = const AsyncLoading<UserState>();
    final result = await ref.read(resetDemoUseCaseProvider).call();
    return result.fold(
      (failure) {
        _setError(failure.message);
        state = AsyncError<UserState>(failure, StackTrace.current);
        return false;
      },
      (fresh) {
        lastError = null;
        state = AsyncData<UserState>(fresh);
        return true;
      },
    );
  }
}
