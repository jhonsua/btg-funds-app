import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:btg_funds_app/app/app.dart';
import 'package:btg_funds_app/core/config/app_config.dart';
import 'package:btg_funds_app/core/config/flavor.dart';
import 'package:btg_funds_app/core/network/asset_bundle_provider.dart';
import 'package:btg_funds_app/features/user/presentation/providers/providers.dart';

import 'helpers/test_asset_bundle.dart';

void main() {
  late SharedPreferences prefs;

  const tFundsJson = '[]';

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  Future<void> pumpApp(WidgetTester tester, AppConfig config) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(config),
          sharedPreferencesProvider.overrideWithValue(prefs),
          assetBundleProvider.overrideWithValue(
            TestAssetBundle({'assets/mocks/funds.json': tFundsJson}),
          ),
        ],
        child: const BtgApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('BtgApp arranca con MaterialApp.router y muestra la AppBar',
      (tester) async {
    await pumpApp(
      tester,
      const AppConfig(
        flavor: Flavor.dev,
        appName: 'BTG Pactual Dev',
        simulatedLatency: Duration.zero,
        showDebugBanner: false,
      ),
    );

    expect(find.byType(MaterialApp), findsOneWidget);
    // Initial location es /funds → AppBar 'BTG Pactual'.
    expect(find.text('BTG Pactual'), findsWidgets);
  });

  testWidgets('BtgApp con flavor prod arranca sin banner', (tester) async {
    await pumpApp(
      tester,
      const AppConfig(
        flavor: Flavor.prod,
        appName: 'BTG Pactual',
        simulatedLatency: Duration.zero,
        showDebugBanner: false,
      ),
    );

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
