import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:btg_funds_app/app/router.dart';
import 'package:btg_funds_app/core/config/app_config.dart';
import 'package:btg_funds_app/core/config/flavor.dart';
import 'package:btg_funds_app/core/network/asset_bundle_provider.dart';
import 'package:btg_funds_app/core/theme/app_theme.dart';
import 'package:btg_funds_app/features/user/presentation/providers/providers.dart';
import 'package:btg_funds_app/shared/widgets/inline_validation_message.dart';

import '../helpers/test_asset_bundle.dart';

void main() {
  late SharedPreferences prefs;

  const tFundsJson = '''
  [
    {"id":"1","name":"FPV_BTG_PACTUAL_RECAUDADORA","minimum_amount":75000,"category":"fpv","description":"Descripción educativa."}
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
    '1. render base: fondo, mínimo, hint del monto, canal email '
    'pre-seleccionado y CTA deshabilitado (sin monto)',
    (tester) async {
      tester.view.physicalSize = const Size(400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await pumpAt(tester, '/funds/1/subscribe');

      expect(find.text('FPV_BTG_PACTUAL_RECAUDADORA'), findsOneWidget);
      expect(find.textContaining('Mínimo'), findsOneWidget);
      expect(find.text('¿Cuánto deseas invertir?'), findsOneWidget);
      // El canal default es email — la tarjeta muestra "Te avisamos por"
      // y un botón "Cambiar".
      expect(find.text('Te avisamos por'), findsOneWidget);
      expect(find.text('Cambiar'), findsOneWidget);
      // CTA deshabilitado por falta de monto (canal ya tiene valor).
      final btn = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Confirmar suscripción'),
      );
      expect(btn.onPressed, isNull);
    },
  );

  testWidgets(
    '2. monto < mínimo muestra InlineValidationMessage warning y deja '
    'el CTA deshabilitado',
    (tester) async {
      tester.view.physicalSize = const Size(400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await pumpAt(tester, '/funds/1/subscribe');

      await tester.enterText(find.byType(TextFormField), '50000');
      await tester.pump();

      expect(find.text('Monto menor al mínimo'), findsOneWidget);
      final InlineValidationMessage msg = tester.widget(
        find.byType(InlineValidationMessage),
      );
      expect(msg.severity, equals(InlineValidationSeverity.warning));

      final btn = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Confirmar suscripción'),
      );
      expect(btn.onPressed, isNull);
    },
  );

  testWidgets(
    '3. monto > saldo muestra InlineValidationMessage error y deja el '
    'CTA deshabilitado',
    (tester) async {
      tester.view.physicalSize = const Size(400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await pumpAt(tester, '/funds/1/subscribe');

      // Saldo default 500.000 → 999.999 > saldo.
      await tester.enterText(find.byType(TextFormField), '999999');
      await tester.pump();

      expect(find.text('Saldo insuficiente'), findsOneWidget);
      final InlineValidationMessage msg = tester.widget(
        find.byType(InlineValidationMessage),
      );
      expect(msg.severity, equals(InlineValidationSeverity.error));

      final btn = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Confirmar suscripción'),
      );
      expect(btn.onPressed, isNull);
    },
  );

  testWidgets(
    '4. monto válido habilita el CTA sin tocar el canal '
    '(email pre-seleccionado)',
    (tester) async {
      tester.view.physicalSize = const Size(400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await pumpAt(tester, '/funds/1/subscribe');

      // Monto válido entre 75.000 y 500.000.
      await tester.enterText(find.byType(TextFormField), '100000');
      await tester.pump();

      // No InlineValidationMessage visible.
      expect(find.byType(InlineValidationMessage), findsNothing);
      // CTA habilitado SIN haber tocado el selector de canal.
      final btn = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Confirmar suscripción'),
      );
      expect(btn.onPressed, isNotNull);
    },
  );

  testWidgets(
    '5. el InlineValidationMessage desaparece al corregir el monto '
    'a un valor válido',
    (tester) async {
      tester.view.physicalSize = const Size(400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await pumpAt(tester, '/funds/1/subscribe');

      // Primer intento: < mínimo → aparece el mensaje.
      await tester.enterText(find.byType(TextFormField), '50000');
      await tester.pump();
      expect(find.byType(InlineValidationMessage), findsOneWidget);

      // Corregir a un valor válido → el mensaje desaparece.
      await tester.enterText(find.byType(TextFormField), '100000');
      await tester.pumpAndSettle();
      expect(find.byType(InlineValidationMessage), findsNothing);

      // Y el CTA queda habilitado.
      final btn = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Confirmar suscripción'),
      );
      expect(btn.onPressed, isNotNull);
    },
  );
}
