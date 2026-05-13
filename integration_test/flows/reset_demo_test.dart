import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:btg_funds_app/features/subscriptions/presentation/widgets/position_card.dart';
import 'package:btg_funds_app/features/transactions/presentation/widgets/transaction_card.dart';

import '../helpers/finders.dart';
import '../helpers/pump_helpers.dart';
import '../helpers/test_setup.dart';

/// Cubre el fix de Etapa 7.5 (commit `e5b09cc`): `ResetDemoUseCase` debe
/// limpiar atómicamente las 3 llaves del demo (balance, subscriptions,
/// transactions) PERO preservar el perfil del usuario (email, phone,
/// preferredChannel).
///
/// Flujo: arrancamos en frío → ensuciamos el estado (2 suscripciones,
/// canal a SMS) → reseteamos → verificamos limpieza total + canal SMS
/// preservado.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Flujo end-to-end: reset demo preserva perfil', () {
    testWidgets(
      'cold start → 2 suscripciones + canal SMS → reset → '
      'estado inicial pero canal SMS preservado',
      (tester) async {
        // Ancla viewport mobile para asegurar NavigationBar (tabs).
        tester.view.physicalSize = const Size(400, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await pumpApp(tester);

        // ── 1. Cold start: lista de fondos visible ──────────────────────
        expect(fundsListScreen, findsOneWidget);

        // ── 2. Saldo inicial $500.000 visible (hero + standard card) ────
        expect(find.text(r'COP $500.000'), findsAtLeastNWidgets(1));

        // ── 3. Suscribir a FPV_BTG_PACTUAL_RECAUDADORA con 100.000 ──────
        await tester.tap(fundCard('FPV_BTG_PACTUAL_RECAUDADORA'));
        await tester.pumpAndSettle();
        expect(fundDetailScreen, findsOneWidget);

        await tester.tap(subscribeButton);
        await tester.pumpAndSettle();
        expect(subscriptionFormScreen, findsOneWidget);

        await tester.enterText(find.byType(TextFormField), '100000');
        await tester.pump();
        await tester.tap(confirmSubscribeButton);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // SnackBar éxito → dismiss explícito antes de continuar.
        ScaffoldMessenger.of(
          tester.element(find.byType(Scaffold).first),
        ).hideCurrentSnackBar();
        await tester.pumpAndSettle();
        await pumpWithAnimations(tester);
        await tester.pumpAndSettle();

        // ── 4. Saldo bajó a $400.000 (500k - 100k) ──────────────────────
        expect(fundsListScreen, findsOneWidget);
        expect(find.text(r'COP $400.000'), findsAtLeastNWidgets(1));

        // ── 5. Suscribir a FDO-ACCIONES con 250.000 ─────────────────────
        // FDO-ACCIONES tiene minimumAmount=250000 (assets/mocks/funds.json).
        // FDO-ACCIONES es el 4º fondo del catálogo: probablemente off-screen
        // a 400x900. Hay que hacer scroll dentro del ListView para que el
        // ListView.builder lo construya y luego sea tappable.
        await tester.scrollUntilVisible(
          fundCard('FDO-ACCIONES'),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
        await tester.tap(fundCard('FDO-ACCIONES'));
        await tester.pumpAndSettle();
        expect(fundDetailScreen, findsOneWidget);

        await tester.tap(subscribeButton);
        await tester.pumpAndSettle();
        expect(subscriptionFormScreen, findsOneWidget);

        await tester.enterText(find.byType(TextFormField), '250000');
        await tester.pump();
        await tester.tap(confirmSubscribeButton);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        ScaffoldMessenger.of(
          tester.element(find.byType(Scaffold).first),
        ).hideCurrentSnackBar();
        await tester.pumpAndSettle();
        await pumpWithAnimations(tester);
        await tester.pumpAndSettle();

        // ── 6. Saldo bajó a $150.000 (400k - 250k) ──────────────────────
        expect(fundsListScreen, findsOneWidget);
        expect(find.text(r'COP $150.000'), findsAtLeastNWidgets(1));

        // ── 7. Tab Posiciones → 2 cards visibles ───────────────────────
        await tester.tap(positionsTab);
        await tester.pumpAndSettle();
        expect(positionsScreen, findsOneWidget);
        expect(find.byType(PositionCard), findsNWidgets(2));
        // Sanity-check: ambos fondos aparecen como posiciones.
        expect(
          positionCard('FPV_BTG_PACTUAL_RECAUDADORA'),
          findsOneWidget,
        );
        expect(positionCard('FDO-ACCIONES'), findsOneWidget);

        // ── 8. Tab Historial → 2 entries de tipo "Suscripción" ─────────
        await tester.tap(historyTab);
        await tester.pumpAndSettle();
        expect(transactionsScreen, findsOneWidget);
        await pumpUntilFound(
          tester,
          find.byType(TransactionCard),
          timeout: const Duration(seconds: 3),
        );
        expect(find.byType(TransactionCard), findsNWidgets(2));
        // El badge "Suscripción" aparece una vez por card (typeLabel).
        expect(find.text('Suscripción'), findsNWidgets(2));
        // "Cancelación" no debe existir aún.
        expect(find.text('Cancelación'), findsNothing);

        // ── 9. Tab Perfil ──────────────────────────────────────────────
        await tester.tap(profileTab);
        await tester.pumpAndSettle();
        expect(profileScreen, findsOneWidget);

        // ── 10. Cambiar canal a SMS ────────────────────────────────────
        // Hallazgo durante D.2: `subscribe_to_fund_usecase.dart` línea 216
        // hace best-effort `updateUser(preferredChannel: channel)` después
        // de cada suscripción. Como las dos suscripciones se hicieron con
        // canal "email" (default del form), `user.preferredChannel` ya es
        // `NotificationChannel.email` cuando entramos a Perfil. Por eso
        // el botón muestra "Correo" (label del enum), no "Preguntar cada
        // vez" (estado vacío).
        //
        // El test sigue siendo válido como verificador del reset porque:
        //   * cambiamos canal Correo → SMS,
        //   * lo guardamos vía updateProfile,
        //   * reseteamos,
        //   * verificamos que sigue siendo SMS post-reset.
        // El "estado limpio" pre-reset es: preferredChannel != null.
        //
        // CUIDADO con el finder de "Correo": el form de Perfil tiene un
        // TextFormField con `labelText: 'Correo'` (profile_screen.dart:197).
        // Ese label también es un `Text('Correo')` en el árbol. Por eso
        // anclamos el tap al OutlinedButton.icon que abre el sheet de
        // canal (profile_screen.dart:231-239).
        final channelButton = find.widgetWithText(
          OutlinedButton,
          'Correo',
        );
        expect(channelButton, findsOneWidget);
        await tester.tap(channelButton);
        await tester.pumpAndSettle();
        // El sheet muestra el title del helper:
        expect(find.text('¿Cómo te avisamos?'), findsOneWidget);
        // Tap en la opción SMS del sheet. Dentro del bottom sheet, "SMS"
        // es texto único (label de NotificationChannel.sms).
        await tester.tap(find.text('SMS'));
        await tester.pumpAndSettle();

        // ── 11. Guardar cambios → SnackBar "Perfil actualizado." ───────
        // El botón "Guardar cambios" se habilita cuando el canal cambia
        // respecto al estado inicial. (_canSave en profile_screen.dart).
        final saveButton = find.widgetWithText(
          ElevatedButton,
          'Guardar cambios',
        );
        // Sanity-check: el botón está habilitado tras cambiar canal.
        final saveBtn = tester.widget<ElevatedButton>(saveButton);
        expect(saveBtn.onPressed, isNotNull);

        await tester.tap(saveButton);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.text('Perfil actualizado.'), findsOneWidget);
        ScaffoldMessenger.of(
          tester.element(find.byType(Scaffold).first),
        ).hideCurrentSnackBar();
        await tester.pumpAndSettle();

        // El label del botón de canal ahora muestra "SMS" (label del enum).
        // Anclamos al OutlinedButton para evitar coupling con otros 'SMS'
        // que pudieran aparecer en el árbol.
        expect(
          find.widgetWithText(OutlinedButton, 'SMS'),
          findsOneWidget,
        );

        // ── 12. Tap "Restablecer cuenta de demo" ────────────────────────
        // El botón está al final de la pantalla; aseguramos visible.
        await tester.ensureVisible(resetDemoButton);
        await tester.pumpAndSettle();
        await tester.tap(resetDemoButton);
        await tester.pumpAndSettle();

        // ── 13. Dialog visible con copy exacto ──────────────────────────
        // Title del dialog (también es el label del botón outlined detrás).
        // Diferenciamos por widget tipo: el AlertDialog usa Text en title.
        expect(
          find.descendant(
            of: find.byType(AlertDialog),
            matching: find.text('Restablecer cuenta de demo'),
          ),
          findsOneWidget,
        );
        // Content: el copy se construye con kInitialBalance.toCop() →
        // "COP $500.000". Usamos textContaining para evitar coupling a
        // posibles wraps con \n.
        expect(
          find.textContaining(
            r'Volverás al estado inicial: saldo COP $500.000',
          ),
          findsOneWidget,
        );
        expect(
          find.textContaining(
            'Tu perfil (email, teléfono, canal) se mantiene.',
          ),
          findsOneWidget,
        );

        // ── 14. Confirmar reset con "Sí, restablecer" ───────────────────
        final confirmResetButton = find.widgetWithText(
          FilledButton,
          'Sí, restablecer',
        );
        expect(confirmResetButton, findsOneWidget);
        await tester.tap(confirmResetButton);
        // SnackBar "Cuenta restablecida al estado inicial." → no settle.
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        expect(
          find.text('Cuenta restablecida al estado inicial.'),
          findsOneWidget,
        );
        ScaffoldMessenger.of(
          tester.element(find.byType(Scaffold).first),
        ).hideCurrentSnackBar();
        await tester.pumpAndSettle();

        // ── 15. Tab Fondos → saldo de vuelta a $500.000 ─────────────────
        await tester.tap(fundsTab);
        await tester.pumpAndSettle();
        expect(fundsListScreen, findsOneWidget);
        expect(find.text(r'COP $500.000'), findsAtLeastNWidgets(1));

        // ── 16. Tab Posiciones → empty state ────────────────────────────
        await tester.tap(positionsTab);
        await tester.pumpAndSettle();
        expect(positionsScreen, findsOneWidget);
        expect(find.byType(PositionCard), findsNothing);
        // Copy del AppEmptyView en positions_screen.dart línea 45.
        expect(find.text('Aún no tienes posiciones activas'), findsOneWidget);

        // ── 17. Tab Historial → 0 transacciones ─────────────────────────
        await tester.tap(historyTab);
        await tester.pumpAndSettle();
        expect(transactionsScreen, findsOneWidget);
        expect(find.byType(TransactionCard), findsNothing);
        // Empty state copy de transactions_screen.dart línea 88.
        expect(find.text('Aún no tienes transacciones'), findsOneWidget);
        // Aserción explícita: los badges "Suscripción"/"Cancelación" no
        // aparecen porque no hay cards.
        expect(find.text('Suscripción'), findsNothing);
        expect(find.text('Cancelación'), findsNothing);

        // ── 18. CRÍTICO: tab Perfil → canal sigue siendo SMS ────────────
        // Este es el verificador clave del fix Etapa 7.5: reset preserva
        // el perfil. Si el use case borrara preferredChannel, aquí
        // veríamos de vuelta "Preguntar cada vez".
        await tester.tap(profileTab);
        await tester.pumpAndSettle();
        expect(profileScreen, findsOneWidget);
        expect(
          find.widgetWithText(OutlinedButton, 'SMS'),
          findsOneWidget,
        );
        // Y la cadena "Preguntar cada vez" NO está visible.
        expect(find.text('Preguntar cada vez'), findsNothing);
      },
    );
  });
}
