import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:btg_funds_app/features/funds/presentation/widgets/fund_card.dart';
import 'package:btg_funds_app/features/subscriptions/presentation/widgets/position_card.dart';
import 'package:btg_funds_app/features/transactions/presentation/widgets/transaction_card.dart';

/// Finders compartidos entre flujos de integration_test.
///
/// Las screens del proyecto exponen `Key('xxx-screen')` en su `Scaffold`
/// raíz (agregado como parte de la setup de integration_test). Los
/// tabs de navegación (`NavigationBar`/`NavigationRail`) se localizan
/// por su label visible, que coincide con el copy real de `HomeShell`.

// ── Screens ───────────────────────────────────────────────────────────────
final fundsListScreen = find.byKey(const ValueKey('funds-list-screen'));
final fundDetailScreen = find.byKey(const ValueKey('fund-detail-screen'));
final subscriptionFormScreen =
    find.byKey(const ValueKey('subscription-form-screen'));
final positionsScreen = find.byKey(const ValueKey('positions-screen'));
final transactionsScreen = find.byKey(const ValueKey('transactions-screen'));
final profileScreen = find.byKey(const ValueKey('profile-screen'));

// ── Tabs ──────────────────────────────────────────────────────────────────
// El label del tab aparece dentro del NavigationBar (mobile) o
// NavigationRail (tablet). Como ambos los renderizan como widget Text,
// el copy real basta. Si en una vista coexisten texto del tab y texto
// dentro del body (ej. el AppBar también dice "Mis posiciones"), usar
// `find.descendant` desde el NavigationBar/Rail.
final fundsTab = find.descendant(
  of: find.byType(NavigationBar),
  matching: find.text('Fondos'),
);
final positionsTab = find.descendant(
  of: find.byType(NavigationBar),
  matching: find.text('Posiciones'),
);
final historyTab = find.descendant(
  of: find.byType(NavigationBar),
  matching: find.text('Historial'),
);
final profileTab = find.descendant(
  of: find.byType(NavigationBar),
  matching: find.text('Perfil'),
);

// ── CTAs (copy real de la app) ────────────────────────────────────────────
final subscribeButton = find.widgetWithText(ElevatedButton, 'Suscribirme');
final confirmSubscribeButton =
    find.widgetWithText(ElevatedButton, 'Confirmar suscripción');
final cancelButton =
    find.widgetWithText(OutlinedButton, 'Cancelar participación');
final confirmCancelButton =
    find.widgetWithText(FilledButton, 'Sí, cancelar participación');
final resetDemoButton = find.widgetWithText(
  OutlinedButton,
  'Restablecer cuenta de demo',
);

// ── Cards por contenido ───────────────────────────────────────────────────
/// Localiza un `FundCard` por el nombre del fondo que muestra. Útil para
/// hacer tap específicamente en el card del fondo deseado dentro de la
/// lista de 5 fondos.
Finder fundCard(String name) => find.ancestor(
      of: find.text(name),
      matching: find.byType(FundCard),
    );

/// Localiza un `PositionCard` por el nombre del fondo que muestra.
Finder positionCard(String fundName) => find.ancestor(
      of: find.text(fundName),
      matching: find.byType(PositionCard),
    );

/// Localiza un `TransactionCard` por el nombre del fondo que muestra.
/// Útil para encontrar transacciones específicas en el historial.
Finder transactionCard(String fundName) => find.ancestor(
      of: find.text(fundName),
      matching: find.byType(TransactionCard),
    );
