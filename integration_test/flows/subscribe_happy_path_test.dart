import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:btg_funds_app/features/subscriptions/presentation/widgets/position_card.dart';
import 'package:btg_funds_app/features/transactions/presentation/widgets/transaction_card.dart';

import '../helpers/finders.dart';
import '../helpers/pump_helpers.dart';
import '../helpers/test_setup.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Flujo end-to-end: suscripción + cancelación', () {
    testWidgets(
      'cold start → suscribir Recaudadora → cancelar → ver historial',
      (tester) async {
        // Anclamos viewport a 400x900 (mobile) para forzar NavigationBar
        // (el helper de finders busca tabs dentro de NavigationBar).
        tester.view.physicalSize = const Size(400, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await pumpApp(tester);

        // ── 1. Cold start: FundsListScreen visible ──────────────────────
        expect(fundsListScreen, findsOneWidget);
        expect(find.text('BTG Pactual'), findsWidgets);

        // ── 2. Saldo inicial: $500.000 (formato es_CO: "COP $500.000") ──
        // El HomeDashboardSection renderea el saldo en el hero negro y
        // adicionalmente en la sección "Capital invertido + Total" (standard
        // card debajo). Por eso findsAtLeastNWidgets(1): nos importa que el
        // saldo correcto se muestre, no en cuántos lugares.
        expect(find.text(r'COP $500.000'), findsAtLeastNWidgets(1));

        // ── 3. Tap en card de FPV_BTG_PACTUAL_RECAUDADORA ───────────────
        // El nombre aparece tanto en FundCard de lista como (potencialmente)
        // en otros lugares; usamos el helper que sube al ancestor FundCard.
        final recaudadoraCard = fundCard('FPV_BTG_PACTUAL_RECAUDADORA');
        expect(recaudadoraCard, findsOneWidget);
        await tester.tap(recaudadoraCard);
        await tester.pumpAndSettle();

        // ── 4. FundDetailScreen visible + botón "Suscribirme" presente ──
        expect(fundDetailScreen, findsOneWidget);
        expect(subscribeButton, findsOneWidget);

        // ── 5. Tap "Suscribirme" ────────────────────────────────────────
        await tester.tap(subscribeButton);
        await tester.pumpAndSettle();

        // ── 6. SubscriptionFormScreen visible + canal email pre-seleccionado ──
        expect(subscriptionFormScreen, findsOneWidget);
        expect(find.text('¿Cuánto deseas invertir?'), findsOneWidget);
        expect(find.text('Te avisamos por'), findsOneWidget);

        // ── 7. Ingresar monto 100.000 ───────────────────────────────────
        await tester.enterText(find.byType(TextFormField), '100000');
        await tester.pump();

        // ── 8. Botón "Confirmar suscripción" habilitado ─────────────────
        final confirmBtn = tester.widget<ElevatedButton>(confirmSubscribeButton);
        expect(confirmBtn.onPressed, isNotNull);

        // ── 9. Tap "Confirmar suscripción" ──────────────────────────────
        await tester.tap(confirmSubscribeButton);
        // No usamos pumpAndSettle aquí porque la SnackBar tiene duración
        // de 4 segundos por defecto. Bombeamos lo justo para que aparezca
        // y para que el context.go('/funds') resuelva.
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // ── 10. SnackBar de éxito "Te suscribiste a ..." ────────────────
        // El copy real del notifier es:
        //   "Te suscribiste a <fundName>. Confirmación enviada a <dest>."
        expect(
          find.textContaining('Te suscribiste a FPV_BTG_PACTUAL_RECAUDADORA'),
          findsOneWidget,
        );

        // ── 10.bis Dismiss explícito del SnackBar (determinístico) ──────
        // SnackBar default persiste 4s y bloquea hit-tests sobre las
        // siguientes pantallas. En lugar de esperar tiempo fijo (anti-
        // patrón en CI), pedimos al ScaffoldMessenger root que oculte el
        // SnackBar ahora. ScaffoldMessenger.of(...) sube por el árbol
        // hasta el provider del MaterialApp, independientemente del
        // Scaffold concreto desde el que se busca.
        ScaffoldMessenger.of(
          tester.element(find.byType(Scaffold).first),
        ).hideCurrentSnackBar();
        await tester.pumpAndSettle();

        // ── 11. La navegación context.go('/funds') vuelve a la lista ────
        // Bombeamos transición del router (220ms fade+slide).
        await pumpWithAnimations(tester);
        await tester.pumpAndSettle();
        expect(fundsListScreen, findsOneWidget);

        // ── 12. Tap tab "Posiciones" ────────────────────────────────────
        expect(positionsTab, findsOneWidget);
        await tester.tap(positionsTab);
        await tester.pumpAndSettle();

        // ── 13. PositionsScreen + FPV_BTG_PACTUAL_RECAUDADORA + 100.000 ──
        expect(positionsScreen, findsOneWidget);
        final posCard = positionCard('FPV_BTG_PACTUAL_RECAUDADORA');
        expect(posCard, findsOneWidget);
        // MoneyDisplay renderea "COP $100.000" para el monto suscrito.
        expect(
          find.descendant(
            of: find.byType(PositionCard),
            matching: find.text(r'COP $100.000'),
          ),
          findsOneWidget,
        );

        // ── 14. Tap en la posición → navega a FundDetailScreen ──────────
        // (fix 7.5: PositionCard ahora navega a /funds/:id, no al dialog)
        await tester.tap(posCard);
        await tester.pumpAndSettle();
        expect(fundDetailScreen, findsOneWidget);

        // ── 15. Tap "Cancelar participación" ────────────────────────────
        // Como ya hay subscripción activa, el botón Cancelar reemplaza
        // al de Suscribirme.
        expect(cancelButton, findsOneWidget);
        await tester.tap(cancelButton);
        await tester.pumpAndSettle();

        // ── 16. Dialog visible con CTA "Sí, cancelar participación" ─────
        expect(confirmCancelButton, findsOneWidget);
        expect(
          find.textContaining('¿Cancelar tu participación en'),
          findsOneWidget,
        );

        // ── 17. Confirmar cancelación ───────────────────────────────────
        await tester.tap(confirmCancelButton);
        // Igual que con la suscripción: pump puntual, no settle, porque
        // la SnackBar dura 4s.
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // ── 18. SnackBar "Cancelaste tu participación..." ───────────────
        expect(
          find.textContaining('Cancelaste tu participación'),
          findsOneWidget,
        );

        // ── 18.bis Dismiss explícito del SnackBar (determinístico) ──────
        // Mismo patrón que el paso 10.bis: hideCurrentSnackBar() en lugar
        // de esperar el auto-dismiss de 4s para evitar flakiness en CI.
        ScaffoldMessenger.of(
          tester.element(find.byType(Scaffold).first),
        ).hideCurrentSnackBar();
        await tester.pumpAndSettle();

        // El context.go('/funds') ya disparó la navegación al disparar el
        // tap. Bombeamos la transición.
        await pumpWithAnimations(tester);
        await tester.pumpAndSettle();
        expect(fundsListScreen, findsOneWidget);

        // ── 19. Tap tab "Historial" ─────────────────────────────────────
        expect(historyTab, findsOneWidget);
        await tester.tap(historyTab);
        await tester.pumpAndSettle();
        expect(transactionsScreen, findsOneWidget);

        // ── 20. 2 transacciones: 1 "Suscripción" + 1 "Cancelación" ──────
        // TransactionCard renderea el typeLabel "Suscripción" o
        // "Cancelación" como badge en la cabecera de la card.
        await pumpUntilFound(
          tester,
          find.byType(TransactionCard),
          timeout: const Duration(seconds: 3),
        );
        expect(find.byType(TransactionCard), findsNWidgets(2));
        expect(find.text('Suscripción'), findsOneWidget);
        expect(find.text('Cancelación'), findsOneWidget);
        // Ambas transacciones son del mismo fondo.
        expect(
          find.descendant(
            of: find.byType(TransactionCard),
            matching: find.text('FPV_BTG_PACTUAL_RECAUDADORA'),
          ),
          findsNWidgets(2),
        );

        // ── 21. Tap tab "Fondos" → saldo de vuelta a 500.000 ────────────
        // Suscribió 100k → 400k. Canceló → 500k. Saldo final igual al inicio.
        await tester.tap(fundsTab);
        await tester.pumpAndSettle();
        expect(fundsListScreen, findsOneWidget);
        // El HeroBalanceCard usa AnimatedSwitcher para mostrar el balance
        // actualizado. Después del settle ya debería estar el valor final.
        // findsAtLeastNWidgets(1) porque el saldo se muestra en hero + standard
        // card debajo (sección "invertido + total").
        expect(find.text(r'COP $500.000'), findsAtLeastNWidgets(1));
      },
    );
  });
}
