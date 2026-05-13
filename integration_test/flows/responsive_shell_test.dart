import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../helpers/finders.dart';
import '../helpers/test_setup.dart';

/// Test 7 (Etapa 8.4) — Responsive shell.
///
/// Valida la transición entre `BottomNavigationBar` (móvil) y
/// `NavigationRail` (desktop/tablet landscape) según el breakpoint
/// `Breakpoints.tablet = 900dp` definido en `lib/core/utils/responsive.dart`
/// y aplicado en `lib/app/home_shell.dart` vía `LayoutBuilder`.
///
/// Dos sub-tests independientes con viewports fijos para evitar la
/// fragilidad de resize mid-test (Forma B): la app real raramente
/// cambia viewport sin recargar, y el rebuild de `LayoutBuilder` en
/// runtime es sensible al timing.
///
/// Cada sub-test usa `tester.binding.setSurfaceSize` ANTES de
/// `pumpApp` para que el primer build del `LayoutBuilder` reciba el
/// tamaño correcto. `addTearDown(setSurfaceSize(null))` restaura el
/// default para los tests subsecuentes en la misma corrida.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Responsive shell: BottomNav (móvil) ↔ NavigationRail (desktop)', () {
    testWidgets(
      'viewport 360dp renderea BottomNavigationBar con 4 tabs y navegación funciona',
      (tester) async {
        // Viewport mobile estándar — por debajo de Breakpoints.tablet (900).
        await tester.binding.setSurfaceSize(const Size(360, 800));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await pumpApp(tester);

        // ── 1. BottomNavigationBar presente ─────────────────────────────
        expect(
          find.byType(NavigationBar),
          findsOneWidget,
          reason:
              'En viewport 360dp debe renderear NavigationBar de Material 3',
        );

        // ── 2. NavigationRail ausente ───────────────────────────────────
        expect(
          find.byType(NavigationRail),
          findsNothing,
          reason: 'En viewport 360dp NO debe haber NavigationRail',
        );

        // ── 3. 4 destinos visibles en el bottom nav ─────────────────────
        // Anclamos dentro de NavigationBar para evitar matches con
        // AppBars o títulos de pantalla que repiten estas palabras.
        expect(
          find.descendant(
            of: find.byType(NavigationBar),
            matching: find.text('Fondos'),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byType(NavigationBar),
            matching: find.text('Posiciones'),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byType(NavigationBar),
            matching: find.text('Historial'),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byType(NavigationBar),
            matching: find.text('Perfil'),
          ),
          findsOneWidget,
        );

        // ── 4. Pantalla inicial = FundsListScreen ───────────────────────
        expect(fundsListScreen, findsOneWidget);

        // ── 5. Navegar a Posiciones ─────────────────────────────────────
        await tester.tap(
          find.descendant(
            of: find.byType(NavigationBar),
            matching: find.text('Posiciones'),
          ),
        );
        await tester.pumpAndSettle();
        expect(positionsScreen, findsOneWidget);

        // ── 6. Navegar a Historial ──────────────────────────────────────
        await tester.tap(
          find.descendant(
            of: find.byType(NavigationBar),
            matching: find.text('Historial'),
          ),
        );
        await tester.pumpAndSettle();
        expect(transactionsScreen, findsOneWidget);

        // ── 7. Navegar a Perfil ─────────────────────────────────────────
        await tester.tap(
          find.descendant(
            of: find.byType(NavigationBar),
            matching: find.text('Perfil'),
          ),
        );
        await tester.pumpAndSettle();
        expect(profileScreen, findsOneWidget);

        // ── 8. Volver a Fondos ──────────────────────────────────────────
        await tester.tap(
          find.descendant(
            of: find.byType(NavigationBar),
            matching: find.text('Fondos'),
          ),
        );
        await tester.pumpAndSettle();
        expect(fundsListScreen, findsOneWidget);
      },
    );

    testWidgets(
      'viewport 1200dp renderea NavigationRail con 4 destinos y navegación funciona',
      (tester) async {
        // Viewport desktop / tablet landscape — por encima de Breakpoints.tablet.
        await tester.binding.setSurfaceSize(const Size(1200, 800));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await pumpApp(tester);

        // ── 1. NavigationRail presente ──────────────────────────────────
        expect(
          find.byType(NavigationRail),
          findsOneWidget,
          reason: 'En viewport 1200dp debe renderear NavigationRail',
        );

        // ── 2. NavigationBar ausente ────────────────────────────────────
        expect(
          find.byType(NavigationBar),
          findsNothing,
          reason: 'En viewport 1200dp NO debe haber BottomNavigationBar',
        );

        // ── 3. 4 destinos visibles en el rail ───────────────────────────
        expect(
          find.descendant(
            of: find.byType(NavigationRail),
            matching: find.text('Fondos'),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byType(NavigationRail),
            matching: find.text('Posiciones'),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byType(NavigationRail),
            matching: find.text('Historial'),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byType(NavigationRail),
            matching: find.text('Perfil'),
          ),
          findsOneWidget,
        );

        // ── 4. Pantalla inicial = FundsListScreen ───────────────────────
        expect(fundsListScreen, findsOneWidget);

        // ── 5. Navegar a Historial via Rail ─────────────────────────────
        await tester.tap(
          find.descendant(
            of: find.byType(NavigationRail),
            matching: find.text('Historial'),
          ),
        );
        await tester.pumpAndSettle();
        expect(transactionsScreen, findsOneWidget);

        // ── 6. Navegar a Posiciones via Rail ────────────────────────────
        await tester.tap(
          find.descendant(
            of: find.byType(NavigationRail),
            matching: find.text('Posiciones'),
          ),
        );
        await tester.pumpAndSettle();
        expect(positionsScreen, findsOneWidget);

        // ── 7. Navegar a Perfil via Rail ────────────────────────────────
        await tester.tap(
          find.descendant(
            of: find.byType(NavigationRail),
            matching: find.text('Perfil'),
          ),
        );
        await tester.pumpAndSettle();
        expect(profileScreen, findsOneWidget);

        // ── 8. Volver a Fondos via Rail ─────────────────────────────────
        await tester.tap(
          find.descendant(
            of: find.byType(NavigationRail),
            matching: find.text('Fondos'),
          ),
        );
        await tester.pumpAndSettle();
        expect(fundsListScreen, findsOneWidget);
      },
    );
  });
}
