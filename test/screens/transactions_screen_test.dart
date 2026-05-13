import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:btg_funds_app/app/router.dart';
import 'package:btg_funds_app/core/config/app_config.dart';
import 'package:btg_funds_app/core/config/flavor.dart';
import 'package:btg_funds_app/core/network/asset_bundle_provider.dart';
import 'package:btg_funds_app/core/theme/app_theme.dart';
import 'package:btg_funds_app/features/transactions/presentation/widgets/filter_trigger_chip.dart';
import 'package:btg_funds_app/features/user/presentation/providers/providers.dart';

import '../helpers/test_asset_bundle.dart';

void main() {
  late SharedPreferences prefs;

  const tFundsJson = '''
  [
    {"id":"1","name":"FPV_BTG_PACTUAL_RECAUDADORA","minimum_amount":75000,"category":"fpv","description":""}
  ]
  ''';

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  Future<void> pumpAt(WidgetTester tester, String location) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(
            const AppConfig(
              flavor: Flavor.dev,
              appName: 'BTG Dev',
              simulatedLatency: Duration.zero,
              showDebugBanner: false,
            ),
          ),
          sharedPreferencesProvider.overrideWithValue(prefs),
          assetBundleProvider.overrideWithValue(
            TestAssetBundle({'assets/mocks/funds.json': tFundsJson}),
          ),
        ],
        child: Consumer(
          builder: (ctx, ref, _) {
            final router = ref.watch(goRouterProvider);
            // ignore: discarded_futures
            Future.microtask(() => router.go(location));
            return MaterialApp.router(
              theme: AppTheme.light,
              routerConfig: router,
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'tap en FilterTriggerChip abre el bottom sheet de filtros',
    (tester) async {
      tester.view.physicalSize = const Size(400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await pumpAt(tester, '/transactions');

      // El chip "Filtrar" está visible en el body (no solo el icono del AppBar).
      expect(find.byType(FilterTriggerChip), findsOneWidget);

      await tester.tap(find.byType(FilterTriggerChip));
      await tester.pumpAndSettle();

      // El bottom sheet expone el título "Filtrar transacciones".
      expect(find.text('Filtrar transacciones'), findsOneWidget);
    },
  );
}
