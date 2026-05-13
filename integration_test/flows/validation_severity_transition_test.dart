import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:btg_funds_app/shared/widgets/inline_validation_message.dart';

import '../helpers/finders.dart';
import '../helpers/test_setup.dart';

/// **Test sustituto del decimal-validation original**
///
/// Hallazgo durante auditoría D.2: el formulario combina
/// `FilteringTextInputFormatter.digitsOnly` + `ThousandsSeparatorFormatter`
/// (subscription_form_screen.dart:241-244). Ambos formatters filtran
/// caracteres no numéricos ANTES de que lleguen al campo. Resultado:
/// teclear `100000.50` produce `10000050` en pantalla. La rama
/// `showDecimal` (línea 209) que dispara el mensaje "Monto inválido / Los
/// aportes en pesos colombianos deben ser cifras enteras" es código
/// efectivamente inalcanzable desde teclado. No es un bug del producto
/// — es una defensa-en-profundidad para entradas no-teclado (autofill,
/// pegado, accesibilidad futura), pero NO se puede validar end-to-end
/// con un integration test que tipea como un usuario real.
///
/// Sustituyo el test decimal por uno que ejercita la transición de
/// severities, que es lo MÁS valioso aún no cubierto: validar que la
/// severity se recalcula correctamente cuando el monto cruza umbrales,
/// y que el icono cambia entre warning ↔ error en tiempo real.
///
/// Flujo:
///   1. Ingresar monto debajo del mínimo  → severity WARNING.
///   2. Ingresar monto sobre el saldo     → severity ERROR (transición).
///   3. Ingresar monto válido            → mensaje desaparece.
///
/// Esto cubre lógica de presentation que ningún unit test cubre:
/// la coexistencia condicional de los tres bloques `if` (showBelowMinimum
/// / showOverBalance / showDecimal) y el reflujo del `AnimatedSize`
/// cuando el contenido cambia.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Validación: transición de severities (warning ↔ error)', () {
    testWidgets(
      'monto < min (warning) → monto > saldo (error) → válido (limpio)',
      (tester) async {
        tester.view.physicalSize = const Size(400, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await pumpApp(tester);

        // ── 1. Cold start: saldo $500.000 ───────────────────────────────
        expect(fundsListScreen, findsOneWidget);

        // ── 2. Tap FPV_BTG_PACTUAL_RECAUDADORA (mínimo $75.000) ─────────
        await tester.tap(fundCard('FPV_BTG_PACTUAL_RECAUDADORA'));
        await tester.pumpAndSettle();
        await tester.tap(subscribeButton);
        await tester.pumpAndSettle();
        expect(subscriptionFormScreen, findsOneWidget);

        final amountField = find.byType(TextFormField);

        // ── 3. FASE A: 30.000 < mínimo (75.000) → severity WARNING ──────
        await tester.enterText(amountField, '30000');
        await tester.pumpAndSettle();
        expect(find.byType(InlineValidationMessage), findsOneWidget);
        expect(find.text('Monto menor al mínimo'), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(InlineValidationMessage),
            matching: find.byIcon(Icons.warning_amber_outlined),
          ),
          findsOneWidget,
          reason: 'monto bajo el mínimo debe mostrar icono warning',
        );
        expect(
          find.descendant(
            of: find.byType(InlineValidationMessage),
            matching: find.byIcon(Icons.error_outline),
          ),
          findsNothing,
          reason: 'no debe haber icono error mientras el caso es warning',
        );
        final btnAfterWarning = tester.widget<ElevatedButton>(
          confirmSubscribeButton,
        );
        expect(btnAfterWarning.onPressed, isNull);

        // ── 4. FASE B: 750.000 > saldo (500.000) → severity ERROR ───────
        // Mismo campo, mismo widget; el InlineValidationMessage debe
        // **mutar** su severity sin destruirse (mismo nodo, distinto
        // contenido). Si la lógica condicional fuera "se construyen
        // ambos a la vez" tendríamos dos mensajes — verificamos que solo
        // hay UNO.
        await tester.enterText(amountField, '750000');
        await tester.pumpAndSettle();
        expect(find.byType(InlineValidationMessage), findsOneWidget);
        expect(find.text('Saldo insuficiente'), findsOneWidget);
        // Y el mensaje warning ya NO está.
        expect(find.text('Monto menor al mínimo'), findsNothing);
        // El icono ahora debe ser error, no warning.
        expect(
          find.descendant(
            of: find.byType(InlineValidationMessage),
            matching: find.byIcon(Icons.error_outline),
          ),
          findsOneWidget,
          reason: 'monto sobre el saldo debe mostrar icono error',
        );
        expect(
          find.descendant(
            of: find.byType(InlineValidationMessage),
            matching: find.byIcon(Icons.warning_amber_outlined),
          ),
          findsNothing,
          reason: 'el icono warning debe haber sido reemplazado',
        );
        final btnAfterError = tester.widget<ElevatedButton>(
          confirmSubscribeButton,
        );
        expect(btnAfterError.onPressed, isNull);

        // ── 5. FASE C: 100.000 (válido) → mensaje limpio + CTA activo ───
        await tester.enterText(amountField, '100000');
        await tester.pumpAndSettle();
        expect(find.byType(InlineValidationMessage), findsNothing);
        expect(find.text('Saldo insuficiente'), findsNothing);
        expect(find.text('Monto menor al mínimo'), findsNothing);
        final btnAfterValid = tester.widget<ElevatedButton>(
          confirmSubscribeButton,
        );
        expect(btnAfterValid.onPressed, isNotNull);
      },
    );
  });
}
