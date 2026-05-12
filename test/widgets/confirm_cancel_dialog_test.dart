import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:btg_funds_app/core/theme/app_theme.dart';
import 'package:btg_funds_app/features/subscriptions/presentation/widgets/confirm_cancel_dialog.dart';

void main() {
  Widget wrap({required Widget child}) {
    return MaterialApp(theme: AppTheme.light, home: Scaffold(body: child));
  }

  testWidgets(
    'renderea nombre del fondo y monto a devolver formateado',
    (tester) async {
      await tester.pumpWidget(
        wrap(
          child: const ConfirmCancelDialog(
            fundName: 'FPV_BTG_PACTUAL_RECAUDADORA',
            amount: 100000,
          ),
        ),
      );

      expect(
        find.textContaining('FPV_BTG_PACTUAL_RECAUDADORA'),
        findsOneWidget,
      );
      expect(find.textContaining('100.000'), findsOneWidget);
      expect(find.text('Volver'), findsOneWidget);
      expect(find.text('Sí, cancelar participación'), findsOneWidget);
    },
  );

  testWidgets(
    'tap en "Sí, cancelar participación" hace pop con true',
    (tester) async {
      bool? result;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await showConfirmCancelDialog(
                    context,
                    fundName: 'Fondo X',
                    amount: 50000,
                  );
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sí, cancelar participación'));
      await tester.pumpAndSettle();

      expect(result, isTrue);
    },
  );
}
