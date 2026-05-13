import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:btg_funds_app/app/router.dart';
import 'package:btg_funds_app/core/config/app_config.dart';
import 'package:btg_funds_app/core/config/flavor.dart';
import 'package:btg_funds_app/core/constants/app_constants.dart';
import 'package:btg_funds_app/core/theme/app_theme.dart';
import 'package:btg_funds_app/features/user/presentation/providers/providers.dart';

/// Levanta la app completa para integration tests con:
///
/// * `SharedPreferences` en modo mock (estado limpio: saldo 500.000,
///   sin posiciones ni transacciones — los defaults del datasource).
/// * `simulatedLatency = Duration.zero` para que los datasources no
///   demoren las lecturas. Esto evita el skeleton shimmer infinito
///   colgando a `pumpAndSettle`.
/// * Locale `es_CO` inicializado (formato de fechas/dinero canónico).
///
/// El widget root replica el patrón de `lib/main_*.dart` y de los widget
/// tests existentes: `ProviderScope` con overrides + `MaterialApp.router`
/// consumiendo `goRouterProvider`. No usamos `BtgApp` directamente
/// porque consume `appConfigProvider.appName` para el title, lo cual no
/// aporta nada al flujo y mantenerlo paralelo a los widget tests
/// minimiza divergencia.
Future<void> pumpApp(WidgetTester tester) async {
  await initializeDateFormatting(kBaseLocale);
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(
          const AppConfig(
            flavor: Flavor.dev,
            appName: 'BTG Pactual Test',
            simulatedLatency: Duration.zero,
            showDebugBanner: false,
          ),
        ),
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: Consumer(
        builder: (ctx, ref, _) {
          final router = ref.watch(goRouterProvider);
          return MaterialApp.router(
            theme: AppTheme.light,
            routerConfig: router,
          );
        },
      ),
    ),
  );
  // Drena el AsyncNotifier inicial (funds, user, subscriptions, transactions).
  // Con latency=0 no hay timers pendientes y settle resuelve rápido.
  await tester.pumpAndSettle();
}
