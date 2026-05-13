import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:btg_funds_app/features/transactions/presentation/widgets/transaction_card.dart';

import '../helpers/finders.dart';
import '../helpers/pump_helpers.dart';
import '../helpers/test_setup.dart';

/// Verifica el flujo de filtros del Historial (Etapa 5 + chip descubrible
/// de Etapa 7.5):
///   * Aplicar filtro de tipo (ChoiceChip "Cancelaciones") → solo
///     cancelaciones visibles.
///   * Aplicar filtro de fondo (DropdownButtonFormField) → solo trans-
///     acciones de ese fondo visibles.
///   * "Limpiar todo" desde ActiveFiltersChips restaura el listado.
///
/// Setup previo: 2 suscripciones + 1 cancelación → estado conocido con
/// 3 transacciones de tipos y fondos diferenciables.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Flujo end-to-end: filtros de Historial', () {
    testWidgets(
      '2 subs + 1 cancel → filtrar por tipo → filtrar por fondo → limpiar',
      (tester) async {
        tester.view.physicalSize = const Size(400, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await pumpApp(tester);

        // ── Setup: 2 suscripciones + 1 cancelación ──────────────────────
        // ── 1. Suscribir a FPV_BTG_PACTUAL_RECAUDADORA (100.000) ────────
        await tester.tap(fundCard('FPV_BTG_PACTUAL_RECAUDADORA'));
        await tester.pumpAndSettle();
        await tester.tap(subscribeButton);
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextFormField), '100000');
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

        // ── 2. Suscribir a FDO-ACCIONES (250.000) ───────────────────────
        // FDO-ACCIONES es el 4º fondo: probablemente off-screen tras la
        // primera suscripción (dashboard creció con _PositionSummaryCard).
        await tester.scrollUntilVisible(
          fundCard('FDO-ACCIONES'),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
        await tester.tap(fundCard('FDO-ACCIONES'));
        await tester.pumpAndSettle();
        await tester.tap(subscribeButton);
        await tester.pumpAndSettle();
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

        // ── 3. Cancelar FPV_BTG_PACTUAL_RECAUDADORA vía Posiciones ──────
        await tester.tap(positionsTab);
        await tester.pumpAndSettle();
        expect(positionsScreen, findsOneWidget);
        await tester.tap(positionCard('FPV_BTG_PACTUAL_RECAUDADORA'));
        await tester.pumpAndSettle();
        expect(fundDetailScreen, findsOneWidget);

        await tester.tap(cancelButton);
        await tester.pumpAndSettle();
        await tester.tap(confirmCancelButton);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        ScaffoldMessenger.of(
          tester.element(find.byType(Scaffold).first),
        ).hideCurrentSnackBar();
        await tester.pumpAndSettle();
        await pumpWithAnimations(tester);
        await tester.pumpAndSettle();

        // ── 4. Tab Historial → 3 entries ────────────────────────────────
        await tester.tap(historyTab);
        await tester.pumpAndSettle();
        expect(transactionsScreen, findsOneWidget);
        await pumpUntilFound(
          tester,
          find.byType(TransactionCard),
          timeout: const Duration(seconds: 3),
        );
        expect(find.byType(TransactionCard), findsNWidgets(3));
        // 2 badges "Suscripción" + 1 "Cancelación" (typeLabel del card).
        expect(find.text('Suscripción'), findsNWidgets(2));
        expect(find.text('Cancelación'), findsOneWidget);

        // ── 5. Tap chip "Filtrar" (FilterTriggerChip, Etapa 7.5) ────────
        // El chip es descubrible: vive sobre la lista y abre el mismo
        // bottom sheet que el icono del AppBar.
        // Hay 2 entry points al filtro: el chip y el IconButton del
        // AppBar (transactions_screen.dart:39-44). Probamos el chip
        // porque es el de mayor valor UX (Etapa 7.5).
        expect(find.text('Filtrar'), findsOneWidget);
        await tester.tap(find.text('Filtrar'));
        await tester.pumpAndSettle();

        // ── 6. Bottom sheet abierto con título "Filtrar transacciones" ──
        expect(find.text('Filtrar transacciones'), findsOneWidget);
        // Las 3 ChoiceChips de tipo visibles: Todos / Suscripciones /
        // Cancelaciones. (filter_bottom_sheet.dart:101-117)
        expect(find.widgetWithText(ChoiceChip, 'Todos'), findsOneWidget);
        expect(
          find.widgetWithText(ChoiceChip, 'Suscripciones'),
          findsOneWidget,
        );
        expect(
          find.widgetWithText(ChoiceChip, 'Cancelaciones'),
          findsOneWidget,
        );

        // ── 7. Seleccionar "Cancelaciones" ──────────────────────────────
        await tester.tap(find.widgetWithText(ChoiceChip, 'Cancelaciones'));
        await tester.pumpAndSettle();

        // ── 8. Tap "Aplicar" → cierra sheet, aplica filtro ──────────────
        await tester.tap(find.widgetWithText(FilledButton, 'Aplicar'));
        // applyFilter es async (transactions_notifier.dart:34-38): pasa
        // por AsyncLoading antes de emitir los txs filtrados. Settle
        // drena ese ciclo + el cierre del bottom sheet.
        await tester.pumpAndSettle();

        // ── 9. Solo 1 transacción visible (la cancelación) ──────────────
        expect(find.byType(TransactionCard), findsOneWidget);
        // El badge "Cancelación" aparece una vez (la única card visible).
        expect(find.text('Cancelación'), findsOneWidget);
        // "Suscripción" no debe aparecer en NINGUNA card visible.
        expect(
          find.descendant(
            of: find.byType(TransactionCard),
            matching: find.text('Suscripción'),
          ),
          findsNothing,
        );

        // ── 10. ActiveFiltersChips muestra "Tipo: Cancelación" ──────────
        // active_filters_chip.dart línea 38: label='Tipo: ${_typeLabel}'.
        // _typeLabel mapea cancellation → 'Cancelación' (singular).
        expect(find.text('Tipo: Cancelación'), findsOneWidget);
        // Y el chip "Limpiar todo" también está visible.
        expect(find.text('Limpiar todo'), findsOneWidget);

        // ── 11. Tap delete icon del chip "Tipo: Cancelación" ────────────
        // InputChip.onDeleted → close button. Es un icono Icons.close
        // size 16 dentro del chip. Lo encontramos vía ancestor=Chip-text.
        // El _Chip widget que envuelve "Tipo: Cancelación" expone el
        // delete icon a 16dp con padding. Usamos find.byTooltip o el
        // ícono directamente; preferimos la entrada por tooltip cuando
        // está disponible. InputChip de Material usa "Remove" como
        // tooltip por defecto, pero el copy depende del locale. Más
        // confiable: localizar el icono Icons.close descendant del chip
        // que contiene "Tipo: Cancelación".
        final clearTipoChip = find.ancestor(
          of: find.text('Tipo: Cancelación'),
          matching: find.byType(InputChip),
        );
        expect(clearTipoChip, findsOneWidget);
        final tipoDeleteIcon = find.descendant(
          of: clearTipoChip,
          matching: find.byIcon(Icons.close),
        );
        expect(tipoDeleteIcon, findsOneWidget);
        await tester.tap(tipoDeleteIcon);
        await tester.pumpAndSettle();

        // ── 12. Las 3 transacciones reaparecen ──────────────────────────
        expect(find.byType(TransactionCard), findsNWidgets(3));
        expect(find.text('Suscripción'), findsNWidgets(2));
        expect(find.text('Cancelación'), findsOneWidget);
        // El chip activo "Tipo: Cancelación" ya no está.
        expect(find.text('Tipo: Cancelación'), findsNothing);
        // Tampoco "Limpiar todo" (sin filtros activos no se renderiza).
        expect(find.text('Limpiar todo'), findsNothing);

        // ── 13. Repetir: filtro por fondo FDO-ACCIONES ──────────────────
        await tester.tap(find.text('Filtrar'));
        await tester.pumpAndSettle();
        expect(find.text('Filtrar transacciones'), findsOneWidget);

        // El DropdownButtonFormField muestra "Todos los fondos" como
        // default (el primer item sin value). Tap para abrir el menú.
        await tester.tap(find.text('Todos los fondos'));
        await tester.pumpAndSettle();

        // El menú dropdown abierto contiene los 5 fondos. El texto
        // "FDO-ACCIONES" aparece UNA vez en el menú porque ese fondo
        // no estaba seleccionado. Tap.
        // Usamos .last como salvavidas si Flutter duplica el item en el
        // overlay durante la transición (caso común con
        // DropdownButtonFormField).
        await tester.tap(find.text('FDO-ACCIONES').last);
        await tester.pumpAndSettle();

        // Aplicar.
        await tester.tap(find.widgetWithText(FilledButton, 'Aplicar'));
        await tester.pumpAndSettle();

        // ── 14. Solo 1 transacción visible (la sub de FDO-ACCIONES) ─────
        expect(find.byType(TransactionCard), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(TransactionCard),
            matching: find.text('FDO-ACCIONES'),
          ),
          findsOneWidget,
        );
        // Recaudadora NO debe aparecer en transactions ahora.
        expect(
          find.descendant(
            of: find.byType(TransactionCard),
            matching: find.text('FPV_BTG_PACTUAL_RECAUDADORA'),
          ),
          findsNothing,
        );
        // Active chip "Fondo: FDO-ACCIONES" visible.
        expect(find.text('Fondo: FDO-ACCIONES'), findsOneWidget);

        // ── 15. "Limpiar todo" → 3 transacciones vuelven ────────────────
        // El "Limpiar todo" es un InputChip con onDeleted → notifier
        // .clearFilter. La interacción correcta es tappear el delete
        // icon (Icons.close), no la etiqueta del chip — tappear el texto
        // del chip no dispara onDeleted (active_filters_chip.dart:68-74,
        // _Chip widget).
        final clearAllChip = find.ancestor(
          of: find.text('Limpiar todo'),
          matching: find.byType(InputChip),
        );
        expect(clearAllChip, findsOneWidget);
        final clearAllDeleteIcon = find.descendant(
          of: clearAllChip,
          matching: find.byIcon(Icons.close),
        );
        expect(clearAllDeleteIcon, findsOneWidget);
        await tester.tap(clearAllDeleteIcon);
        await tester.pumpAndSettle();
        expect(find.byType(TransactionCard), findsNWidgets(3));
        // Y los chips activos desaparecen.
        expect(find.text('Fondo: FDO-ACCIONES'), findsNothing);
        expect(find.text('Limpiar todo'), findsNothing);
      },
    );
  });
}
