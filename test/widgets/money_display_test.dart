import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:btg_funds_app/core/theme/app_text_styles.dart';
import 'package:btg_funds_app/core/theme/app_theme.dart';
import 'package:btg_funds_app/shared/widgets/money_display.dart';

import '../helpers/test_locale.dart';

void main() {
  setUpAll(() async {
    await setupTestLocale();
  });

  Widget wrap(Widget child) {
    return MaterialApp(theme: AppTheme.light, home: Scaffold(body: child));
  }

  testWidgets('MoneyDisplay formatea 100000 a "COP \$100.000"', (tester) async {
    await tester.pumpWidget(wrap(const MoneyDisplay(amount: 100000)));

    expect(find.text('COP \$100.000'), findsOneWidget);
  });

  testWidgets('MoneyDisplay con showCurrency = false omite el prefijo',
      (tester) async {
    await tester.pumpWidget(
      wrap(const MoneyDisplay(amount: 100000, showCurrency: false)),
    );

    expect(find.text('100.000'), findsOneWidget);
    expect(find.textContaining('COP'), findsNothing);
  });

  testWidgets('MoneyDisplay aplica el style provisto', (tester) async {
    await tester.pumpWidget(
      wrap(
        const MoneyDisplay(
          amount: 500000,
          style: AppTextStyles.moneyHero,
        ),
      ),
    );

    final text = tester.widget<Text>(find.byType(Text));
    expect(text.style, equals(AppTextStyles.moneyHero));
  });
}
