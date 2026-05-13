import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:btg_funds_app/shared/widgets/inline_validation_message.dart';

import '../helpers/finders.dart';
import '../helpers/test_setup.dart';

/// Verifica el `InlineValidationMessage` severity ERROR cuando el monto
/// supera el saldo disponible.
///
/// Reglas validadas (subscription_form_screen.dart líneas 207-208 y
/// 271-287):
///   * Condición `amt > user.balance` (showOverBalance).
///   * Severity default = error → icono `Icons.error_outline`.
///   * Contexts: "Tu intento" y "Saldo disponible" como pares label/valor.
///   * Botón "Confirmar suscripción" deshabilitado mientras el error está
///     activo.
///   * Al corregir el monto, el mensaje desaparece (AnimatedSize 200ms)
///     y el botón se rehabilita.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Validación: saldo insuficiente', () {
    testWidgets(
      'monto > saldo dispara error → corregir limpia mensaje y habilita CTA',
      (tester) async {
        tester.view.physicalSize = const Size(400, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await pumpApp(tester);

        // ── 1. Cold start: saldo $500.000 ───────────────────────────────
        expect(fundsListScreen, findsOneWidget);
        expect(find.text(r'COP $500.000'), findsAtLeastNWidgets(1));

        // ── 2. Tap fondo → tap Suscribirme ──────────────────────────────
        await tester.tap(fundCard('FPV_BTG_PACTUAL_RECAUDADORA'));
        await tester.pumpAndSettle();
        expect(fundDetailScreen, findsOneWidget);

        await tester.tap(subscribeButton);
        await tester.pumpAndSettle();
        expect(subscriptionFormScreen, findsOneWidget);

        // Sanity-check: aún no hay mensaje de validación visible.
        expect(find.byType(InlineValidationMessage), findsNothing);

        // ── 3. Ingresar monto 999.999.999 (muy superior a 500.000) ──────
        // ThousandsSeparatorFormatter convierte a "999.999.999" en pantalla
        // pero el modelo lee dígitos crudos → 999_999_999.
        await tester.enterText(find.byType(TextFormField), '999999999');
        // pumpAndSettle drena los 200ms del AnimatedSize del mensaje.
        await tester.pumpAndSettle();

        // ── 4. Mensaje "Saldo insuficiente" visible ─────────────────────
        // Title literal del widget (subscription_form_screen.dart:273).
        expect(find.byType(InlineValidationMessage), findsOneWidget);
        expect(find.text('Saldo insuficiente'), findsOneWidget);
        // Description literal.
        expect(
          find.textContaining(
            'El monto supera tu saldo disponible.',
          ),
          findsOneWidget,
        );

        // ── 5. Severity ERROR: icono Icons.error_outline ────────────────
        // InlineValidationMessage usa el icon como severity discriminator
        // (inline_validation_message.dart líneas 55-64).
        expect(
          find.descendant(
            of: find.byType(InlineValidationMessage),
            matching: find.byIcon(Icons.error_outline),
          ),
          findsOneWidget,
        );
        // Y NO debe ser warning ni info.
        expect(
          find.descendant(
            of: find.byType(InlineValidationMessage),
            matching: find.byIcon(Icons.warning_amber_outlined),
          ),
          findsNothing,
        );

        // ── 6. Contexts: "Tu intento" + "Saldo disponible" formateados ──
        // Los labels llevan ":" agregado por el widget (línea 114).
        expect(find.text('Tu intento:'), findsOneWidget);
        expect(find.text('Saldo disponible:'), findsOneWidget);
        // Valores numéricos formateados (es_CO, MoneyFormat extension).
        // El "COP $999.999.999" aparece DUPLICADO en pantalla: una vez
        // dentro del InlineValidationMessage ("Tu intento") y otra dentro
        // de la summary card "Vas a invertir" (subscription_form_screen.
        // dart:309-313). Anclamos al widget de validación para precisar.
        expect(
          find.descendant(
            of: find.byType(InlineValidationMessage),
            matching: find.text(r'COP $999.999.999'),
          ),
          findsOneWidget,
        );
        // El saldo $500.000 también puede aparecer en múltiples lugares:
        // anclamos al widget de validación.
        expect(
          find.descendant(
            of: find.byType(InlineValidationMessage),
            matching: find.text(r'COP $500.000'),
          ),
          findsOneWidget,
        );

        // ── 7. Botón "Confirmar suscripción" deshabilitado ──────────────
        // _canSubmit retorna false porque amount > balance
        // (subscription_form_screen.dart:74).
        final confirmBtn =
            tester.widget<ElevatedButton>(confirmSubscribeButton);
        expect(confirmBtn.onPressed, isNull);

        // ── 8. Corregir el monto a 100.000 (válido) ─────────────────────
        await tester.enterText(find.byType(TextFormField), '100000');
        await tester.pumpAndSettle();

        // ── 9. Mensaje desaparece + botón habilitado ────────────────────
        expect(find.byType(InlineValidationMessage), findsNothing);
        expect(find.text('Saldo insuficiente'), findsNothing);
        final confirmBtnEnabled = tester.widget<ElevatedButton>(
          confirmSubscribeButton,
        );
        expect(confirmBtnEnabled.onPressed, isNotNull);
      },
    );
  });
}
