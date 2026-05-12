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
import 'package:btg_funds_app/shared/widgets/app_button.dart';
import 'package:btg_funds_app/shared/widgets/inline_validation_message.dart';

import '../helpers/test_asset_bundle.dart';

void main() {
  late SharedPreferences prefs;

  const tFundsJson = '[]';

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
    'email inválido muestra InlineValidationMessage error y deshabilita '
    '"Guardar cambios"',
    (tester) async {
      tester.view.physicalSize = const Size(400, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await pumpAt(tester, '/profile');

      // El email default usuario@btgpactual.co es válido y no muestra mensaje.
      expect(find.byType(InlineValidationMessage), findsNothing);

      // Cambiar email a uno inválido.
      final emailField = find.widgetWithText(TextFormField, 'Correo');
      await tester.enterText(emailField, 'sin-arroba');
      await tester.pumpAndSettle();

      expect(find.text('Correo electrónico inválido'), findsOneWidget);
      final msg = tester.widget<InlineValidationMessage>(
        find.byType(InlineValidationMessage),
      );
      expect(msg.severity, equals(InlineValidationSeverity.error));

      // "Guardar cambios" deshabilitado.
      final saveBtn = find.widgetWithText(AppButton, 'Guardar cambios');
      final AppButton btn = tester.widget(saveBtn);
      expect(btn.onPressed, isNull);
    },
  );

  testWidgets(
    'teléfono inválido muestra InlineValidationMessage error',
    (tester) async {
      tester.view.physicalSize = const Size(400, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await pumpAt(tester, '/profile');

      // Cambiar teléfono a uno inválido (sin +57).
      final phoneField = find.widgetWithText(TextFormField, 'Teléfono');
      await tester.enterText(phoneField, '3001234567');
      await tester.pumpAndSettle();

      expect(find.text('Teléfono inválido'), findsOneWidget);
      final msg = tester.widget<InlineValidationMessage>(
        find.byType(InlineValidationMessage),
      );
      expect(msg.severity, equals(InlineValidationSeverity.error));
    },
  );

  testWidgets(
    '"Guardar cambios" deshabilitado si email O phone inválidos, '
    'habilitado cuando ambos son válidos Y hay cambios',
    (tester) async {
      tester.view.physicalSize = const Size(400, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await pumpAt(tester, '/profile');

      AppButton saveBtn() => tester.widget<AppButton>(
            find.widgetWithText(AppButton, 'Guardar cambios'),
          );

      // Estado inicial: sin cambios → deshabilitado.
      expect(saveBtn().onPressed, isNull);

      // Email inválido → deshabilitado.
      final emailField = find.widgetWithText(TextFormField, 'Correo');
      await tester.enterText(emailField, 'sin-arroba');
      await tester.pumpAndSettle();
      expect(saveBtn().onPressed, isNull);

      // Corregir email a uno válido (distinto al inicial) →
      // ambos válidos y hay cambio → habilitado.
      await tester.enterText(emailField, 'nuevo@btgpactual.co');
      await tester.pumpAndSettle();
      expect(saveBtn().onPressed, isNotNull);

      // Phone inválido → deshabilitado de nuevo.
      final phoneField = find.widgetWithText(TextFormField, 'Teléfono');
      await tester.enterText(phoneField, '300');
      await tester.pumpAndSettle();
      expect(saveBtn().onPressed, isNull);
    },
  );
}
