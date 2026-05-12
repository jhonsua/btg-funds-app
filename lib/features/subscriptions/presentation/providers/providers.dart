import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:btg_funds_app/core/clock.dart';
import 'package:btg_funds_app/core/storage/atomic_write.dart';
import 'package:btg_funds_app/core/uuid_provider.dart';
import 'package:btg_funds_app/features/funds/presentation/providers/providers.dart';
import 'package:btg_funds_app/features/subscriptions/data/datasources/local_subscription_datasource.dart';
import 'package:btg_funds_app/features/subscriptions/data/datasources/shared_prefs_subscription_datasource.dart';
import 'package:btg_funds_app/features/subscriptions/data/repositories/subscription_repository_impl.dart';
import 'package:btg_funds_app/features/subscriptions/domain/entities/subscription.dart';
import 'package:btg_funds_app/features/subscriptions/domain/repositories/subscription_repository.dart';
import 'package:btg_funds_app/features/subscriptions/domain/usecases/cancel_subscription_usecase.dart';
import 'package:btg_funds_app/features/subscriptions/domain/usecases/get_subscriptions_usecase.dart';
import 'package:btg_funds_app/features/subscriptions/domain/usecases/subscribe_to_fund_usecase.dart';
import 'package:btg_funds_app/features/subscriptions/presentation/notifiers/subscription_notifier.dart';
import 'package:btg_funds_app/features/subscriptions/presentation/notifiers/subscription_state.dart';
import 'package:btg_funds_app/features/subscriptions/presentation/notifiers/subscriptions_list_notifier.dart';
import 'package:btg_funds_app/features/transactions/presentation/providers/providers.dart';
import 'package:btg_funds_app/features/user/presentation/providers/providers.dart';

// ── Datasource ─────────────────────────────────────────────────────────
final localSubscriptionDatasourceProvider =
    Provider<LocalSubscriptionDatasource>((ref) {
  return SharedPrefsSubscriptionDatasource(
    ref.watch(sharedPreferencesProvider),
  );
});

// ── Repository ─────────────────────────────────────────────────────────
final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  return SubscriptionRepositoryImpl(
    ref.watch(localSubscriptionDatasourceProvider),
  );
});

// ── Use cases ──────────────────────────────────────────────────────────
final getSubscriptionsUseCaseProvider = Provider<GetSubscriptionsUseCase>((
  ref,
) {
  return GetSubscriptionsUseCase(ref.watch(subscriptionRepositoryProvider));
});

final subscribeToFundUseCaseProvider = Provider<SubscribeToFundUseCase>((ref) {
  return SubscribeToFundUseCase(
    addTransactionUseCase: ref.watch(addTransactionUseCaseProvider),
    atomicWrite: ref.watch(atomicWriteProvider),
    clock: ref.watch(clockProvider),
    getFundByIdUseCase: ref.watch(getFundByIdUseCaseProvider),
    subscriptionRepository: ref.watch(subscriptionRepositoryProvider),
    transactionRepository: ref.watch(transactionRepositoryProvider),
    uuid: ref.watch(uuidProvider),
    userRepository: ref.watch(userRepositoryProvider),
  );
});

final cancelSubscriptionUseCaseProvider = Provider<CancelSubscriptionUseCase>((
  ref,
) {
  return CancelSubscriptionUseCase(
    addTransactionUseCase: ref.watch(addTransactionUseCaseProvider),
    atomicWrite: ref.watch(atomicWriteProvider),
    subscriptionRepository: ref.watch(subscriptionRepositoryProvider),
    transactionRepository: ref.watch(transactionRepositoryProvider),
    userRepository: ref.watch(userRepositoryProvider),
  );
});

// ── Notifiers ──────────────────────────────────────────────────────────
final subscriptionNotifierProvider =
    NotifierProvider<SubscriptionNotifier, SubscriptionState>(
  SubscriptionNotifier.new,
);

final subscriptionsListNotifierProvider =
    AsyncNotifierProvider<SubscriptionsListNotifier, List<Subscription>>(
  SubscriptionsListNotifier.new,
);
