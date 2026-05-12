import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:btg_funds_app/features/funds/domain/entities/fund.dart';
import 'package:btg_funds_app/features/funds/presentation/providers/providers.dart';

class FundsNotifier extends AsyncNotifier<List<Fund>> {
  String? lastError;

  void _setError(String message) {
    lastError = message;
  }

  @override
  Future<List<Fund>> build() async {
    final result = await ref.read(getFundsUseCaseProvider).call();
    return result.fold(
      (failure) {
        _setError(failure.message);
        throw failure;
      },
      (funds) {
        lastError = null;
        return funds;
      },
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading<List<Fund>>();
    state = await AsyncValue.guard(() async {
      final result = await ref.read(getFundsUseCaseProvider).call();
      return result.fold(
        (failure) {
          _setError(failure.message);
          throw failure;
        },
        (funds) {
          lastError = null;
          return funds;
        },
      );
    });
  }
}
