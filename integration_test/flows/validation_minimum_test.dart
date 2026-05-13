import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:btg_funds_app/shared/widgets/inline_validation_message.dart';

import '../helpers/finders.dart';
import '../helpers/test_setup.dart';

/// Verifica `InlineValidationMessage` severity WARNING cuando el monto
/// es menor al mínimo del fondo.
///
/// Reglas validadas (subscription_form_screen.dart líneas 207, 255-270):
///   * Condición `amt > 0 && amt < fund.minimumAmount` (showBelowMinimum).
///   * Severity = warning → icono `Icons.warning_amber_outlined` (NO
///     `Icons.error_outline`). Esta distinción es lo que diferencia el
///     mensaje "informativo" del crítico de saldo insuficiente.
///   * Contexts: "Monto mínimo" + "Tu intento".
///   * Botón "Confirmar suscripción" deshabilitado.
///   * Corregir a monto válido limpia mensaje y habilita CTA.
///
/// FPV_BTG_PACTUAL_RECAUDADORA tiene minimumAmount=75000 en
/// assets/mocks/funds.json. Probamos con 50.000 (debajo del mínimo).
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Validación: monto menor al mínimo', () {
    testWidgets(
      'monto < mínimo dispara warning (no error) → corregir limpia CTA',
      (tester) async {
        tester.view.physicalSize = const Size(400, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await pumpApp(tester);

        // ── 1. Cold start ───────────────────────────────────────────────
        expect(fundsListScreen, findsOneWidget);

        // ── 2. Tap FPV_BTG_PACTUAL_RECAUDADORA (mínimo $75.000) ─────────
        await tester.tap(fundCard('FPV_BTG_PACTUAL_RECAUDADORA'));
        await tester.pumpAndSettle();
        expect(fundDetailScreen, findsOneWidget);

        // ── 3. Tap Suscribirme ──────────────────────────────────────────
        await tester.tap(subscribeButton);
        await tester.pumpAndSettle();
        expect(subscriptionFormScreen, findsOneWidget);

        // Sanity-check: el form muestra el mínimo del fondo arriba.
        // Copy: "Mínimo COP $75.000" (subscription_form_screen.dart:227).
        expect(find.text(r'Mínimo COP $75.000'), findsOneWidget);
        // Y aún no hay mensaje de validación.
        expect(find.byType(InlineValidationMessage), findsNothing);

        // ── 4. Ingresar 50.000 (debajo del mínimo de 75.000) ────────────
        await tester.enterText(find.byType(TextFormField), '50000');
        await tester.pumpAndSettle();

        // ── 5. Mensaje "Monto menor al mínimo" visible ──────────────────
        expect(find.byType(InlineValidationMessage), findsOneWidget);
        expect(find.text('Monto menor al mínimo'), findsOneWidget);
        // Description literal (subscription_form_screen.dart:259).
        expect(
          find.text('Este fondo requiere un monto de apertura mayor.'),
          findsOneWidget,
        );

        // ── 6. Severity WARNING: icono Icons.warning_amber_outlined ─────
        // CRÍTICO: este test diferencia warning de error. Si el icon fuera
        // Icons.error_outline el test falla, validando que la severity
        // está bien cableada en presentation.
        expect(
          find.descendant(
            of: find.byType(InlineValidationMessage),
            matching: find.byIcon(Icons.warning_amber_outlined),
          ),
          findsOneWidget,
        );
        // Y NO debe ser error.
        expect(
          find.descendant(
            of: find.byType(InlineValidationMessage),
            matching: find.byIcon(Icons.error_outline),
          ),
          findsNothing,
        );

        // ── 7. Contexts: "Monto mínimo" + "Tu intento" ──────────────────
        expect(find.text('Monto mínimo:'), findsOneWidget);
        expect(find.text('Tu intento:'), findsOneWidget);
        // Valores numéricos formateados (es_CO). Anclamos al widget de
        // validación porque "COP $50.000" también aparece duplicado en la
        // summary card "Vas a invertir" y "COP $75.000" aparece en el
        // header del fondo ("Mínimo COP $75.000").
        expect(
          find.descendant(
            of: find.byType(InlineValidationMessage),
            matching: find.text(r'COP $75.000'),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byType(InlineValidationMessage),
            matching: find.text(r'COP $50.000'),
          ),
          findsOneWidget,
        );

        // ── 8. Botón deshabilitado ──────────────────────────────────────
        final confirmBtn =
            tester.widget<ElevatedButton>(confirmSubscribeButton);
        expect(confirmBtn.onPressed, isNull);

        // ── 9. Corregir a 75.000 (exacto al mínimo, válido) ─────────────
        await tester.enterText(find.byType(TextFormField), '75000');
        await tester.pumpAndSettle();

        // ── 10. Mensaje desaparece + botón habilitado ───────────────────
        // Validamos que ya no hay InlineValidationMessage en pantalla
        // (ningún tipo, error ni warning ni info).
        expect(find.byType(InlineValidationMessage), findsNothing);
        expect(find.text('Monto menor al mínimo'), findsNothing);
        final confirmBtnEnabled = tester.widget<ElevatedButton>(
          confirmSubscribeButton,
        );
        expect(confirmBtnEnabled.onPressed, isNotNull);
      },
    );
  });
}
