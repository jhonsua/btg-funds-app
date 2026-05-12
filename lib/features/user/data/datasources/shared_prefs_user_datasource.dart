import 'package:shared_preferences/shared_preferences.dart';

import 'package:btg_funds_app/core/constants/app_constants.dart';
import 'package:btg_funds_app/core/errors/exceptions.dart';
import 'package:btg_funds_app/features/user/data/datasources/local_user_datasource.dart';
import 'package:btg_funds_app/features/user/domain/entities/notification_channel.dart';
import 'package:btg_funds_app/features/user/domain/entities/user_state.dart';

/// Persistencia local del estado del usuario sobre [SharedPreferences].
///
/// Decisión: NO existe `UserStateModel` separado de [UserState] porque cada
/// campo se almacena en su propia key (no hay JSON intermedio). Este datasource
/// construye [UserState] directamente desde los reads individuales.
///
/// Cold start: si la key no existe en prefs, retorna el valor default canónico
/// definido en `lib/core/constants/app_constants.dart`. NO se lanza
/// [CacheException] en ese caso — primer arranque es estado válido.
///
/// Patrón de rollback (a aplicar en Etapa 4 — subscribe/cancel):
///   1. Leer balance actual → guardar como `rollbackBalance`.
///   2. `acquire()` en OperationLock (que se introducirá en Etapa 4).
///   3. `setBalance(newBalance)`.
///   4. Persistir la subscription / transaction.
///   5. Si paso 4 falla → `setBalance(rollbackBalance)` para revertir.
///   6. `release()` al cierre exitoso.
/// En Etapa 2 (solo update profile) no hay transferencia → escrituras
/// independientes idempotentes, sin rollback necesario.
class SharedPrefsUserDatasource implements LocalUserDatasource {
  SharedPrefsUserDatasource(this._prefs);

  static const _kBalance = 'user.balance';
  static const _kEmail = 'user.email';
  static const _kPhone = 'user.phone';
  static const _kChannel = 'user.channel';

  final SharedPreferences _prefs;

  @override
  Future<UserState> getUser() async {
    try {
      final balance = _prefs.getDouble(_kBalance) ?? kInitialBalance;
      final email = _prefs.getString(_kEmail) ?? kInitialEmail;
      final phone = _prefs.getString(_kPhone) ?? kInitialPhone;
      final channelName = _prefs.getString(_kChannel);
      final preferredChannel = _channelFromName(channelName);
      return UserState(
        balance: balance,
        email: email,
        phone: phone,
        preferredChannel: preferredChannel,
      );
    } catch (e) {
      throw CacheException('Error leyendo el estado del usuario: $e');
    }
  }

  @override
  Future<double> getBalance() async {
    try {
      return _prefs.getDouble(_kBalance) ?? kInitialBalance;
    } catch (e) {
      throw CacheException('Error leyendo el saldo: $e');
    }
  }

  @override
  Future<void> setBalance(double newBalance) async {
    final ok = await _prefs.setDouble(_kBalance, newBalance);
    if (!ok) {
      throw const CacheException('No se pudo guardar el saldo.');
    }
  }

  @override
  Future<UserState> setUser({
    String? email,
    String? phone,
    NotificationChannel? preferredChannel,
  }) async {
    try {
      if (email != null) {
        final ok = await _prefs.setString(_kEmail, email);
        if (!ok) throw const CacheException('No se pudo guardar el correo.');
      }
      if (phone != null) {
        final ok = await _prefs.setString(_kPhone, phone);
        if (!ok) throw const CacheException('No se pudo guardar el teléfono.');
      }
      if (preferredChannel != null) {
        final ok = await _prefs.setString(_kChannel, preferredChannel.name);
        if (!ok) throw const CacheException('No se pudo guardar el canal.');
      }
      return getUser();
    } on CacheException {
      rethrow;
    } catch (e) {
      throw CacheException('Error guardando el perfil: $e');
    }
  }

  @override
  Future<UserState> reset() async {
    try {
      await _prefs.remove(_kBalance);
      await _prefs.remove(_kEmail);
      await _prefs.remove(_kPhone);
      await _prefs.remove(_kChannel);
      return getUser();
    } catch (e) {
      throw CacheException('Error restableciendo la cuenta de demo: $e');
    }
  }

  /// `null` si la key no existe o si el valor está corrupto (no matchea un
  /// nombre conocido del enum). NO se lanza excepción: una preferencia
  /// inválida no debe romper la app, sólo perderse silenciosamente.
  NotificationChannel? _channelFromName(String? name) {
    if (name == null || name.isEmpty) return null;
    try {
      return NotificationChannel.values.byName(name);
    } catch (_) {
      return null;
    }
  }
}
