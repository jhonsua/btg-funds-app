import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:btg_funds_app/core/errors/exceptions.dart';
import 'package:btg_funds_app/core/storage/storage_keys.dart';
import 'package:btg_funds_app/features/subscriptions/data/datasources/local_subscription_datasource.dart';
import 'package:btg_funds_app/features/subscriptions/data/models/subscription_model.dart';

class SharedPrefsSubscriptionDatasource implements LocalSubscriptionDatasource {
  SharedPrefsSubscriptionDatasource(
    this._prefs, {
    Duration latency = Duration.zero,
  }) : _latency = latency;

  final SharedPreferences _prefs;
  final Duration _latency;

  @override
  Future<List<SubscriptionModel>> getSubscriptions() async {
    try {
      // Delay simulado para mostrar loading state premium (skeleton shimmer).
      // Solo aplica a la lectura. Mutaciones (write) deben sentirse instantáneas.
      if (_latency > Duration.zero) {
        await Future<void>.delayed(_latency);
      }
      final raw = _prefs.getString(StorageKeys.userSubscriptions);
      if (raw == null || raw.isEmpty) return const [];
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        throw const CacheException(
          'Datos de suscripciones corruptos: se esperaba un array.',
        );
      }
      return decoded
          .map((e) => SubscriptionModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on CacheException {
      rethrow;
    } catch (e) {
      throw CacheException('Error leyendo las suscripciones: $e');
    }
  }
}
