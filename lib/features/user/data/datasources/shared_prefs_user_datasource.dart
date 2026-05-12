import 'package:shared_preferences/shared_preferences.dart';

import 'package:btg_funds_app/core/constants/app_constants.dart';
import 'package:btg_funds_app/core/errors/exceptions.dart';
import 'package:btg_funds_app/core/storage/storage_keys.dart';
import 'package:btg_funds_app/features/user/data/datasources/local_user_datasource.dart';
import 'package:btg_funds_app/features/user/domain/entities/notification_channel.dart';
import 'package:btg_funds_app/features/user/domain/entities/user_state.dart';

/// Persistencia local del estado del usuario sobre [SharedPreferences].
///
/// Decisión: NO existe `UserStateModel` separado de [UserState] porque cada
/// campo se almacena en su propia key (no hay JSON intermedio).
///
/// Cold start: si la key no existe en prefs, retorna el valor default canónico
/// definido en `lib/core/constants/app_constants.dart`. NO se lanza
/// [CacheException] en ese caso — primer arranque es estado válido.
///
/// **Etapa 4: `userBalance` se persiste como String** (no double) para
/// que `AtomicWrite` pueda manejarlo junto con `userSubscriptions` y
/// `userTransactions` en commits atómicos. Conversión a/desde [double]
/// se hace localmente en este datasource.
class SharedPrefsUserDatasource implements LocalUserDatasource {
  SharedPrefsUserDatasource(this._prefs);

  final SharedPreferences _prefs;

  @override
  Future<UserState> getUser() async {
    try {
      final balance = _readBalance();
      final email = _prefs.getString(StorageKeys.userEmail) ?? kInitialEmail;
      final phone = _prefs.getString(StorageKeys.userPhone) ?? kInitialPhone;
      final preferredChannel =
          _channelFromName(_prefs.getString(StorageKeys.userChannel));
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
      return _readBalance();
    } catch (e) {
      throw CacheException('Error leyendo el saldo: $e');
    }
  }

  @override
  Future<void> setBalance(double newBalance) async {
    final ok = await _prefs.setString(
      StorageKeys.userBalance,
      newBalance.toString(),
    );
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
        final ok = await _prefs.setString(StorageKeys.userEmail, email);
        if (!ok) throw const CacheException('No se pudo guardar el correo.');
      }
      if (phone != null) {
        final ok = await _prefs.setString(StorageKeys.userPhone, phone);
        if (!ok) throw const CacheException('No se pudo guardar el teléfono.');
      }
      if (preferredChannel != null) {
        final ok = await _prefs.setString(
          StorageKeys.userChannel,
          preferredChannel.name,
        );
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
      await _prefs.remove(StorageKeys.userBalance);
      await _prefs.remove(StorageKeys.userEmail);
      await _prefs.remove(StorageKeys.userPhone);
      await _prefs.remove(StorageKeys.userChannel);
      return getUser();
    } catch (e) {
      throw CacheException('Error restableciendo la cuenta de demo: $e');
    }
  }

  double _readBalance() {
    final raw = _prefs.getString(StorageKeys.userBalance);
    if (raw == null || raw.isEmpty) return kInitialBalance;
    return double.tryParse(raw) ?? kInitialBalance;
  }

  /// `null` si la key no existe o si el valor está corrupto.
  NotificationChannel? _channelFromName(String? name) {
    if (name == null || name.isEmpty) return null;
    try {
      return NotificationChannel.values.byName(name);
    } catch (_) {
      return null;
    }
  }
}
