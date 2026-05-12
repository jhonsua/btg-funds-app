import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:btg_funds_app/core/theme/app_theme.dart';
import 'package:btg_funds_app/shared/widgets/app_button.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(theme: AppTheme.light, home: Scaffold(body: child));
  }

  testWidgets('AppButton primario renderea el label y dispara onPressed',
      (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      wrap(
        AppButton(
          label: 'Confirmar',
          onPressed: () => taps++,
        ),
      ),
    );

    expect(find.text('Confirmar'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(taps, equals(1));
  });

  testWidgets('AppButton variant secondary usa OutlinedButton', (tester) async {
    await tester.pumpWidget(
      wrap(
        AppButton(
          label: 'Cancelar',
          variant: AppButtonVariant.secondary,
          onPressed: () {},
        ),
      ),
    );

    expect(find.byType(OutlinedButton), findsOneWidget);
    expect(find.byType(ElevatedButton), findsNothing);
  });

  testWidgets('AppButton con isLoading muestra spinner y deshabilita el tap',
      (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      wrap(
        AppButton(
          label: 'Confirmar',
          isLoading: true,
          onPressed: () => taps++,
        ),
      ),
    );

    expect(find.text('Confirmar'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(taps, equals(0));
  });
}
