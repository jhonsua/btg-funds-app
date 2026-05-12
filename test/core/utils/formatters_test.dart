import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:btg_funds_app/core/utils/formatters.dart';

import '../../helpers/test_locale.dart';

void main() {
  setUpAll(() async {
    await setupTestLocale();
  });

  group('toCop', () {
    test('formatea un entero con separadores de miles y prefijo COP', () {
      expect(100000.toCop(), equals('COP \$100.000'));
    });

    test('formatea cero como COP \$0', () {
      expect(0.toCop(), equals('COP \$0'));
    });

    test('antepone el signo negativo antes del prefijo de moneda', () {
      expect((-1500).toCop(), equals('-COP \$1.500'));
    });

    test('con showSymbol = false omite el prefijo COP \$', () {
      expect(100000.toCop(showSymbol: false), equals('100.000'));
    });
  });

  group('ThousandsSeparatorFormatter', () {
    final formatter = ThousandsSeparatorFormatter();

    test('formatea 1000000 a 1.000.000 cuando el cursor está al final', () {
      const oldValue = TextEditingValue.empty;
      const newValue = TextEditingValue(
        text: '1000000',
        selection: TextSelection.collapsed(offset: 7),
      );

      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, equals('1.000.000'));
      expect(result.selection.baseOffset, equals(result.text.length));
    });

    test(
      'preserva la posición del cursor cuando se inserta un dígito en medio',
      () {
        // El usuario tenía "12" con cursor en pos 1 (entre 1 y 2),
        // inserta "3": newValue.text = "132" con cursor en pos 2.
        const oldValue = TextEditingValue(
          text: '12',
          selection: TextSelection.collapsed(offset: 1),
        );
        const newValue = TextEditingValue(
          text: '132',
          selection: TextSelection.collapsed(offset: 2),
        );

        final result = formatter.formatEditUpdate(oldValue, newValue);

        // 132 → "132" (sin separador todavía, número < 1000).
        // Cursor debe quedar después del "3" insertado (pos 2),
        // NO al final.
        expect(result.text, equals('132'));
        expect(result.selection.baseOffset, equals(2));
      },
    );

    test(
      'al insertar en medio de un número de 4 dígitos mantiene cursor sobre el dígito recién escrito',
      () {
        // Estado: "1.234" con cursor justo después del "2" (pos 3),
        // el usuario escribe "5" → newValue.text = "12.534" con cursor pos ?.
        // Realmente el InputFormatter recibe newValue antes del re-format,
        // así que simulamos lo que envía el framework: text con el nuevo
        // dígito tal cual, sin re-format.
        const oldValue = TextEditingValue(
          text: '1.234',
          selection: TextSelection.collapsed(offset: 3),
        );
        const newValue = TextEditingValue(
          text: '1.2534',
          selection: TextSelection.collapsed(offset: 4),
        );

        final result = formatter.formatEditUpdate(oldValue, newValue);

        // Dígitos: 1, 2, 5, 3, 4 → formateado: "12.534".
        // Cursor: 3 dígitos a la izquierda del cursor en newValue
        // ("1", "2", "5") → debe quedar justo después del "5" (3er dígito)
        // en "12.534". El "5" está en índice 3, así que el cursor termina
        // en índice 4.
        expect(result.text, equals('12.534'));
        expect(result.selection.baseOffset, equals(4));
      },
    );
  });
}
