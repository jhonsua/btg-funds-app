import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:btg_funds_app/features/user/data/datasources/local_user_datasource.dart';
import 'package:btg_funds_app/features/user/data/datasources/shared_prefs_user_datasource.dart';
import 'package:btg_funds_app/features/user/data/repositories/user_repository_impl.dart';
import 'package:btg_funds_app/features/user/domain/entities/user_state.dart';
import 'package:btg_funds_app/features/user/domain/repositories/user_repository.dart';
import 'package:btg_funds_app/features/user/domain/usecases/get_balance_usecase.dart';
import 'package:btg_funds_app/features/user/domain/usecases/get_user_usecase.dart';
import 'package:btg_funds_app/features/user/domain/usecases/reset_demo_usecase.dart';
import 'package:btg_funds_app/features/user/domain/usecases/update_user_usecase.dart';
import 'package:btg_funds_app/features/user/presentation/notifiers/user_notifier.dart';

/// Override obligatorio en `main_*.dart` con el resultado de
/// `await SharedPreferences.getInstance()`.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (_) => throw UnimplementedError(
    'sharedPreferencesProvider debe ser overrideado en main_dev.dart o '
    'main_prod.dart',
  ),
);

// ── Datasources ────────────────────────────────────────────────────────
final localUserDatasourceProvider = Provider<LocalUserDatasource>((ref) {
  return SharedPrefsUserDatasource(ref.watch(sharedPreferencesProvider));
});

// ── Repositories ───────────────────────────────────────────────────────
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImpl(ref.watch(localUserDatasourceProvider));
});

// ── Use cases ──────────────────────────────────────────────────────────
final getUserUseCaseProvider = Provider<GetUserUseCase>((ref) {
  return GetUserUseCase(ref.watch(userRepositoryProvider));
});

final getBalanceUseCaseProvider = Provider<GetBalanceUseCase>((ref) {
  return GetBalanceUseCase(ref.watch(userRepositoryProvider));
});

final updateUserUseCaseProvider = Provider<UpdateUserUseCase>((ref) {
  return UpdateUserUseCase(ref.watch(userRepositoryProvider));
});

final resetDemoUseCaseProvider = Provider<ResetDemoUseCase>((ref) {
  return ResetDemoUseCase(ref.watch(userRepositoryProvider));
});

// ── Notifier ──────────────────────────────────────────────────────────
final userNotifierProvider =
    AsyncNotifierProvider<UserNotifier, UserState>(UserNotifier.new);

// ── Derivados ─────────────────────────────────────────────────────────
/// Saldo del usuario derivado del [UserState]. Re-render fino: la Home
/// puede consumir sólo este provider sin watch del estado completo.
///
/// Default 0.0 durante loading/error es **sólo para display**. Lógica de
/// negocio (e.g. validar saldo en subscribe) debe usar
/// [GetBalanceUseCase] directamente.
final userBalanceProvider = Provider<double>((ref) {
  return ref.watch(userNotifierProvider).valueOrNull?.balance ?? 0.0;
});
