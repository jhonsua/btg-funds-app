import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:btg_funds_app/app/router.dart';
import 'package:btg_funds_app/core/config/app_config.dart';
import 'package:btg_funds_app/core/config/flavor.dart';
import 'package:btg_funds_app/core/network/asset_bundle_provider.dart';
import 'package:btg_funds_app/core/theme/app_theme.dart';
import 'package:btg_funds_app/features/funds/presentation/widgets/fund_card.dart';
import 'package:btg_funds_app/features/user/presentation/providers/providers.dart';

import '../helpers/test_asset_bundle.dart';

void main() {
  late SharedPreferences prefs;

  const tFundsJson = '''
  [
    {"id":"1","name":"FPV_BTG_PACTUAL_RECAUDADORA","minimum_amount":75000,"category":"fpv","description":""},
    {"id":"2","name":"FPV_BTG_PACTUAL_ECOPETROL","minimum_amount":125000,"category":"fpv","description":""},
    {"id":"3","name":"DEUDAPRIVADA","minimum_amount":50000,"category":"fic","description":""},
    {"id":"4","name":"FDO-ACCIONES","minimum_amount":250000,"category":"fic","description":""},
    {"id":"5","name":"FPV_BTG_PACTUAL_DINAMICA","minimum_amount":100000,"category":"fpv","description":""}
  ]
  ''';

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  Future<void> pumpApp(WidgetTester tester) async {
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
            return MaterialApp.router(
              theme: AppTheme.light,
              routerConfig: router,
            );
          },
        ),
      ),
    );
    // Pump más allá del primer frame para que los AsyncNotifiers resuelvan.
    await tester.pumpAndSettle();
  }

  testWidgets(
    'en 320dp ancho, FundsListScreen no produce overflow visible',
    (tester) async {
      tester.view.physicalSize = const Size(320, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await pumpApp(tester);

      // Los 5 FundCards deben renderizar sin error de overflow.
      expect(find.byType(FundCard), findsNWidgets(5));
      // tester.takeException() retorna cualquier error de layout no manejado.
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'FundsListScreen muestra el header "Fondos disponibles" y nombres truncables',
    (tester) async {
      tester.view.physicalSize = const Size(360, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await pumpApp(tester);

      expect(find.text('Fondos disponibles'), findsOneWidget);
      expect(find.text('FPV_BTG_PACTUAL_RECAUDADORA'), findsOneWidget);
    },
  );
}
