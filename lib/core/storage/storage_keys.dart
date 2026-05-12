/// Keys centralizadas de `shared_preferences`. Mantener aquí evita drift y
/// hace explícito qué keys son atómicas (`userBalance`, `userSubscriptions`,
/// `userTransactions`) vs. independientes.
class StorageKeys {
  StorageKeys._();

  static const userBalance = 'user.balance';
  static const userEmail = 'user.email';
  static const userPhone = 'user.phone';
  static const userChannel = 'user.channel';

  static const userSubscriptions = 'user.subscriptions';
  static const userTransactions = 'user.transactions';

  /// Stage area de [AtomicWrite]. Si la app crashea entre stage y commit,
  /// este valor puede usarse para recuperación manual (no implementado
  /// automáticamente — fuera de scope).
  static const pendingWrite = '_pendingWrite';
}
