import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:btg_funds_app/app/app.dart';
import 'package:btg_funds_app/core/config/app_config.dart';
import 'package:btg_funds_app/core/config/flavor.dart';

void main() {
  Widget buildSubject(AppConfig config) {
    return ProviderScope(
      overrides: [appConfigProvider.overrideWithValue(config)],
      child: const BtgApp(),
    );
  }

  testWidgets('BtgApp con flavor dev muestra "BTG Pactual Dev"',
      (tester) async {
    await tester.pumpWidget(
      buildSubject(
        const AppConfig(
          flavor: Flavor.dev,
          appName: 'BTG Pactual Dev',
          simulatedLatency: Duration(milliseconds: 600),
          showDebugBanner: true,
        ),
      ),
    );

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('BTG Pactual Dev'), findsWidgets);
  });

  testWidgets('BtgApp con flavor prod muestra "BTG Pactual"', (tester) async {
    await tester.pumpWidget(
      buildSubject(
        const AppConfig(
          flavor: Flavor.prod,
          appName: 'BTG Pactual',
          simulatedLatency: Duration(milliseconds: 300),
          showDebugBanner: false,
        ),
      ),
    );

    expect(find.text('BTG Pactual'), findsWidgets);
    expect(find.text('BTG Pactual Dev'), findsNothing);
  });
}
