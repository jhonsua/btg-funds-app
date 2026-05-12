import 'package:flutter_test/flutter_test.dart';

import 'package:btg_funds_app/core/errors/exceptions.dart';
import 'package:btg_funds_app/core/storage/atomic_write.dart';
import 'package:btg_funds_app/core/storage/storage_keys.dart';

/// Fake store con DI funcional. Permite forzar fallos en keys específicas
/// para verificar atomicidad (stage falla / commit falla / revert).
class _FakeStore {
  final Map<String, String> data = {};
  final Set<String> failingWrites = {};

  String? read(String key) => data[key];

  Future<bool> write(String key, String value) async {
    if (failingWrites.contains(key)) return false;
    data[key] = value;
    return true;
  }

  Future<bool> remove(String key) async {
    data.remove(key);
    return true;
  }
}

AtomicWrite _build(_FakeStore store) {
  return AtomicWrite(
    read: store.read,
    write: store.write,
    remove: store.remove,
  );
}

void main() {
  group('AtomicWrite.commit', () {
    test('escribe todas las keys y limpia _pendingWrite tras éxito', () async {
      final store = _FakeStore();
      final writer = _build(store);

      await writer.commit({
        StorageKeys.userBalance: '425000.0',
        StorageKeys.userSubscriptions: '[]',
        StorageKeys.userTransactions: '[]',
      });

      expect(store.data[StorageKeys.userBalance], equals('425000.0'));
      expect(store.data[StorageKeys.userSubscriptions], equals('[]'));
      expect(store.data[StorageKeys.userTransactions], equals('[]'));
      expect(store.data.containsKey(StorageKeys.pendingWrite), isFalse);
    });

    test(
      'falla en stage (write retorna false en _pendingWrite) → lanza '
      'CacheException sin tocar keys reales',
      () async {
        final store = _FakeStore()
          ..data[StorageKeys.userBalance] = '500000.0'
          ..failingWrites.add(StorageKeys.pendingWrite);
        final writer = _build(store);

        await expectLater(
          writer.commit({
            StorageKeys.userBalance: '425000.0',
            StorageKeys.userSubscriptions: '[]',
          }),
          throwsA(isA<CacheException>()),
        );

        // Estado no cambió.
        expect(store.data[StorageKeys.userBalance], equals('500000.0'));
        expect(
          store.data.containsKey(StorageKeys.userSubscriptions),
          isFalse,
        );
      },
    );

    test(
      'falla en commit de la 3ra key → revierte las 2 ya escritas y '
      'lanza CacheException',
      () async {
        final store = _FakeStore()
          ..data[StorageKeys.userBalance] = '500000.0'
          ..data[StorageKeys.userSubscriptions] = '[]'
          ..failingWrites.add(StorageKeys.userTransactions);
        final writer = _build(store);

        await expectLater(
          writer.commit({
            StorageKeys.userBalance: '425000.0',
            StorageKeys.userSubscriptions: '[{"x":1}]',
            StorageKeys.userTransactions: '[{"y":1}]',
          }),
          throwsA(isA<CacheException>()),
        );

        // Rollback: balance + subscriptions restauradas al backup.
        expect(store.data[StorageKeys.userBalance], equals('500000.0'));
        expect(store.data[StorageKeys.userSubscriptions], equals('[]'));
        // userTransactions nunca se escribió (estaba en failingWrites).
        expect(
          store.data.containsKey(StorageKeys.userTransactions),
          isFalse,
        );
        // _pendingWrite limpiado.
        expect(store.data.containsKey(StorageKeys.pendingWrite), isFalse);
      },
    );

    test('commit con mapa vacío es no-op', () async {
      final store = _FakeStore();
      final writer = _build(store);

      await writer.commit({});

      expect(store.data, isEmpty);
    });
  });
}
