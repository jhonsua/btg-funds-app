import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:btg_funds_app/core/errors/exceptions.dart';
import 'package:btg_funds_app/core/storage/storage_keys.dart';
import 'package:btg_funds_app/features/subscriptions/data/datasources/shared_prefs_subscription_datasource.dart';
import 'package:btg_funds_app/features/subscriptions/data/models/subscription_model.dart';
import 'package:btg_funds_app/features/user/domain/entities/notification_channel.dart';

void main() {
  late SharedPreferences prefs;
  late SharedPrefsSubscriptionDatasource datasource;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    datasource = SharedPrefsSubscriptionDatasource(prefs);
  });

  group('SharedPrefsSubscriptionDatasource', () {
    test('cold start retorna lista vacía', () async {
      final subs = await datasource.getSubscriptions();
      expect(subs, isEmpty);
    });

    test(
      'datos persistidos previamente se parsean correctamente',
      () async {
        final raw = jsonEncode([
          SubscriptionModel(
            id: 'sub_1',
            fundId: 'f1',
            fundName: 'Fondo X',
            amount: 100000,
            openedAt: DateTime.utc(2026, 5, 12),
            channel: NotificationChannel.email,
          ).toJson(),
        ]);
        SharedPreferences.setMockInitialValues({
          StorageKeys.userSubscriptions: raw,
        });
        prefs = await SharedPreferences.getInstance();
        datasource = SharedPrefsSubscriptionDatasource(prefs);

        final subs = await datasource.getSubscriptions();

        expect(subs.length, equals(1));
        expect(subs.first.id, equals('sub_1'));
        expect(subs.first.channel, equals(NotificationChannel.email));
      },
    );

    test(
      'JSON corrupto (no es array) lanza CacheException',
      () async {
        SharedPreferences.setMockInitialValues({
          StorageKeys.userSubscriptions: '{"id":"x"}',
        });
        prefs = await SharedPreferences.getInstance();
        datasource = SharedPrefsSubscriptionDatasource(prefs);

        await expectLater(
          datasource.getSubscriptions(),
          throwsA(isA<CacheException>()),
        );
      },
    );

    test(
      'subscription con campo requerido faltante lanza CacheException',
      () async {
        SharedPreferences.setMockInitialValues({
          StorageKeys.userSubscriptions: '[{"id":"x"}]', // sin fundId, etc.
        });
        prefs = await SharedPreferences.getInstance();
        datasource = SharedPrefsSubscriptionDatasource(prefs);

        await expectLater(
          datasource.getSubscriptions(),
          throwsA(isA<CacheException>()),
        );
      },
    );
  });
}
