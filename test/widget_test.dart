import 'package:btg_funds_app/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('BtgApp arranca y renderiza un MaterialApp', (tester) async {
    await tester.pumpWidget(const BtgApp());

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('BTG Pactual'), findsWidgets);
  });

  testWidgets('BtgApp muestra el flavor label cuando se provee',
      (tester) async {
    await tester.pumpWidget(const BtgApp(flavorLabel: 'Dev'));

    expect(find.text('BTG Pactual Dev'), findsWidgets);
  });
}
