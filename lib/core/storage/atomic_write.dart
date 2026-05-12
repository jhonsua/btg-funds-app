import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:btg_funds_app/core/errors/exceptions.dart';
import 'package:btg_funds_app/core/storage/storage_keys.dart';
import 'package:btg_funds_app/features/user/presentation/providers/providers.dart';

/// Simula atomicidad sobre `shared_preferences` (que no es transaccional)
/// con patrón **stage + commit**:
///
/// 1. Stage: serializa el `Map<String, String>` completo a JSON y lo
///    persiste en una única key ([StorageKeys.pendingWrite]) — la
///    escritura más cercana a "atómica" que la API permite.
/// 2. Backup: captura el valor previo (`getString`) de cada key real.
/// 3. Commit: escribe cada key real con `setString`. Si alguna falla,
///    restaura los valores backed up (rollback best effort) y propaga
///    [CacheException].
/// 4. Cleanup: borra [StorageKeys.pendingWrite] al final exitoso.
///
/// El helper acepta funciones inyectadas para `read/write/remove` (DI
/// funcional) para que los tests puedan forzar fallos en keys específicas
/// sin tener que mockear [SharedPreferences] (clase concreta).
class AtomicWrite {
  AtomicWrite({
    required String? Function(String key) read,
    required Future<bool> Function(String key, String value) write,
    required Future<bool> Function(String key) remove,
  })  : _read = read,
        _write = write,
        _remove = remove;

  factory AtomicWrite.fromPrefs(SharedPreferences prefs) => AtomicWrite(
        read: prefs.getString,
        write: prefs.setString,
        remove: prefs.remove,
      );

  final String? Function(String) _read;
  final Future<bool> Function(String, String) _write;
  final Future<bool> Function(String) _remove;

  /// Aplica [writes] atómicamente. Si alguna escritura falla, ninguna
  /// queda visible: las que ya se persistieron se restauran a su valor
  /// previo (best effort) y se lanza [CacheException].
  ///
  /// Un mapa vacío es no-op.
  Future<void> commit(Map<String, String> writes) async {
    if (writes.isEmpty) return;

    // 1. Stage: una sola escritura serializada.
    final stageOk = await _write(StorageKeys.pendingWrite, jsonEncode(writes));
    if (!stageOk) {
      throw const CacheException(
        'No se pudo preparar la escritura atómica.',
      );
    }

    // 2. Backup de los valores actuales (para rollback).
    final backup = <String, String?>{
      for (final key in writes.keys) key: _read(key),
    };

    // 3. Commit en orden.
    final committed = <String>[];
    try {
      for (final entry in writes.entries) {
        final ok = await _write(entry.key, entry.value);
        if (!ok) {
          throw CacheException(
            'Falló la escritura definitiva de "${entry.key}".',
          );
        }
        committed.add(entry.key);
      }
      // 4. Cleanup de la stage area.
      await _remove(StorageKeys.pendingWrite);
    } catch (e) {
      // Rollback de las keys ya commiteadas.
      for (final key in committed) {
        final original = backup[key];
        if (original == null) {
          await _remove(key);
        } else {
          await _write(key, original);
        }
      }
      await _remove(StorageKeys.pendingWrite);
      if (e is CacheException) rethrow;
      throw CacheException('Error en commit atómico: $e');
    }
  }
}

final atomicWriteProvider = Provider<AtomicWrite>((ref) {
  return AtomicWrite.fromPrefs(ref.watch(sharedPreferencesProvider));
});
