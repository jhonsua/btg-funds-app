import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:btg_funds_app/core/errors/exceptions.dart';
import 'package:btg_funds_app/core/storage/storage_keys.dart';
import 'package:btg_funds_app/features/transactions/data/datasources/local_transaction_datasource.dart';
import 'package:btg_funds_app/features/transactions/data/models/transaction_model.dart';

class SharedPrefsTransactionDatasource implements LocalTransactionDatasource {
  SharedPrefsTransactionDatasource(
    this._prefs, {
    Duration latency = Duration.zero,
  }) : _latency = latency;

  final SharedPreferences _prefs;
  final Duration _latency;

  @override
  Future<List<TransactionModel>> getTransactions() async {
    // Delay simulado para mostrar loading state premium (skeleton shimmer).
    // Solo aplica a la lectura pública. `addTransaction` (mutación) usa
    // `_readAllInternal` para evitar el delay y sentirse instantánea.
    if (_latency > Duration.zero) {
      await Future<void>.delayed(_latency);
    }
    return _readAllInternal();
  }

  Future<List<TransactionModel>> _readAllInternal() async {
    try {
      final raw = _prefs.getString(StorageKeys.userTransactions);
      if (raw == null || raw.isEmpty) return const [];
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        throw const CacheException(
          'Datos de transacciones corruptos: se esperaba un array.',
        );
      }
      return decoded
          .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on CacheException {
      rethrow;
    } catch (e) {
      throw CacheException('Error leyendo las transacciones: $e');
    }
  }

  @override
  Future<void> addTransaction(TransactionModel model) async {
    try {
      final current = await _readAllInternal();
      final updated = [...current, model];
      final encoded = jsonEncode(updated.map((m) => m.toJson()).toList());
      final ok = await _prefs.setString(StorageKeys.userTransactions, encoded);
      if (!ok) {
        throw const CacheException('No se pudo guardar la transacción.');
      }
    } on CacheException {
      rethrow;
    } catch (e) {
      throw CacheException('Error guardando la transacción: $e');
    }
  }
}
