import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:btg_funds_app/core/constants/app_constants.dart';
import 'package:btg_funds_app/core/storage/storage_keys.dart';
import 'package:btg_funds_app/features/user/data/datasources/shared_prefs_user_datasource.dart';
import 'package:btg_funds_app/features/user/domain/entities/notification_channel.dart';

void main() {
  late SharedPreferences prefs;
  late SharedPrefsUserDatasource datasource;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    datasource = SharedPrefsUserDatasource(prefs);
  });

  group('SharedPrefsUserDatasource — cold start', () {
    test(
      'getUser sin datos previos retorna los defaults canónicos (sin lanzar)',
      () async {
        final user = await datasource.getUser();

        expect(user.balance, equals(kInitialBalance));
        expect(user.email, equals(kInitialEmail));
        expect(user.phone, equals(kInitialPhone));
        expect(user.preferredChannel, isNull);
      },
    );
  });

  group('SharedPrefsUserDatasource — escritura y lectura', () {
    test('setUser persiste todos los campos y se reflejan en getUser',
        () async {
      await datasource.setUser(
        email: 'nuevo@btgpactual.co',
        phone: '+57 300 111 2222',
        preferredChannel: NotificationChannel.sms,
      );

      final user = await datasource.getUser();
      expect(user.email, equals('nuevo@btgpactual.co'));
      expect(user.phone, equals('+57 300 111 2222'));
      expect(user.preferredChannel, equals(NotificationChannel.sms));
    });

    test('NotificationChannel persiste como String en prefs (channel.name)',
        () async {
      await datasource.setUser(preferredChannel: NotificationChannel.email);

      expect(prefs.getString(StorageKeys.userChannel), equals('email'));
    });

    test('setBalance escribe y getBalance lee el mismo valor', () async {
      await datasource.setBalance(425000);

      expect(await datasource.getBalance(), equals(425000));
    });

    test(
      'setBalance persiste el balance como String (Etapa 4 — compat AtomicWrite)',
      () async {
        await datasource.setBalance(425000);

        // Si fuera double-storage, prefs.getString retornaría null.
        expect(prefs.getString(StorageKeys.userBalance), equals('425000.0'));
      },
    );

    test(
      'channel con valor inválido en prefs no rompe getString del balance',
      () async {
        SharedPreferences.setMockInitialValues({
          StorageKeys.userBalance: '500000.0',
        });
        prefs = await SharedPreferences.getInstance();
        datasource = SharedPrefsUserDatasource(prefs);

        expect(await datasource.getBalance(), equals(500000));
      },
    );

    test('reset() limpia todo y deja el datasource en cold start', () async {
      await datasource.setUser(
        email: 'tampered@x.co',
        phone: '+57 301 999 8888',
        preferredChannel: NotificationChannel.sms,
      );
      await datasource.setBalance(123);

      final fresh = await datasource.reset();

      expect(fresh.balance, equals(kInitialBalance));
      expect(fresh.email, equals(kInitialEmail));
      expect(fresh.phone, equals(kInitialPhone));
      expect(fresh.preferredChannel, isNull);
    });
  });

  group('SharedPrefsUserDatasource — robustez', () {
    test(
      'channel con valor desconocido en prefs se ignora silenciosamente',
      () async {
        // Simulamos prefs corruptas con un nombre de enum que ya no existe.
        SharedPreferences.setMockInitialValues({
          StorageKeys.userChannel: 'whatsapp',
        });
        prefs = await SharedPreferences.getInstance();
        datasource = SharedPrefsUserDatasource(prefs);

        final user = await datasource.getUser();

        expect(user.preferredChannel, isNull);
      },
    );
  });
}
