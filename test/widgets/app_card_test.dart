import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:btg_funds_app/core/theme/app_theme.dart';
import 'package:btg_funds_app/shared/widgets/app_card.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(theme: AppTheme.light, home: Scaffold(body: child));
  }

  testWidgets('AppCard renderea su child', (tester) async {
    await tester.pumpWidget(
      wrap(const AppCard(child: Text('Contenido'))),
    );

    expect(find.text('Contenido'), findsOneWidget);
  });

  testWidgets('AppCard con onTap es tappable y dispara el callback',
      (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      wrap(
        AppCard(
          onTap: () => taps++,
          child: const Text('Tapable'),
        ),
      ),
    );

    await tester.tap(find.text('Tapable'));
    await tester.pump();

    expect(taps, equals(1));
  });
}
