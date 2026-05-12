import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:btg_funds_app/core/config/app_config.dart';
import 'package:btg_funds_app/core/network/asset_bundle_provider.dart';
import 'package:btg_funds_app/features/funds/data/datasources/fund_remote_datasource.dart';
import 'package:btg_funds_app/features/funds/data/datasources/mock_fund_remote_datasource.dart';
import 'package:btg_funds_app/features/funds/data/repositories/fund_repository_impl.dart';
import 'package:btg_funds_app/features/funds/domain/entities/fund.dart';
import 'package:btg_funds_app/features/funds/domain/repositories/fund_repository.dart';
import 'package:btg_funds_app/features/funds/domain/usecases/get_fund_by_id_usecase.dart';
import 'package:btg_funds_app/features/funds/domain/usecases/get_funds_usecase.dart';
import 'package:btg_funds_app/features/funds/presentation/notifiers/funds_notifier.dart';

// ── Datasources ────────────────────────────────────────────────────────
final fundRemoteDatasourceProvider = Provider<FundRemoteDatasource>((ref) {
  return MockFundRemoteDatasource(
    bundle: ref.watch(assetBundleProvider),
    latency: ref.watch(appConfigProvider).simulatedLatency,
  );
});

// ── Repositories ───────────────────────────────────────────────────────
final fundRepositoryProvider = Provider<FundRepository>((ref) {
  return FundRepositoryImpl(ref.watch(fundRemoteDatasourceProvider));
});

// ── Use cases ──────────────────────────────────────────────────────────
final getFundsUseCaseProvider = Provider<GetFundsUseCase>((ref) {
  return GetFundsUseCase(ref.watch(fundRepositoryProvider));
});

final getFundByIdUseCaseProvider = Provider<GetFundByIdUseCase>((ref) {
  return GetFundByIdUseCase(ref.watch(fundRepositoryProvider));
});

// ── Notifier ──────────────────────────────────────────────────────────
final fundsNotifierProvider =
    AsyncNotifierProvider<FundsNotifier, List<Fund>>(FundsNotifier.new);

/// Provider familia para obtener un fondo por id. Lanza el [Failure] si
/// el id no existe (lo cual se renderea como `AsyncError` en la UI).
final fundByIdProvider = FutureProvider.family<Fund, String>((ref, id) async {
  final result = await ref.watch(getFundByIdUseCaseProvider).call(id);
  return result.fold((failure) => throw failure, (fund) => fund);
});
