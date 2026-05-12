import 'package:flutter_test/flutter_test.dart';

import 'package:btg_funds_app/core/utils/validators.dart';

void main() {
  group('Validators.email', () {
    test('null para email válido', () {
      expect(Validators.email('usuario@btgpactual.co'), isNull);
    });

    test('mensaje cuando falta el @', () {
      expect(Validators.email('usuariobtg.com'), equals('Correo inválido.'));
    });

    test('mensaje cuando falta el TLD', () {
      expect(Validators.email('usuario@btg'), equals('Correo inválido.'));
    });

    test('mensaje cuando está vacío', () {
      expect(Validators.email(''), equals('Ingresa tu correo.'));
      expect(Validators.email(null), equals('Ingresa tu correo.'));
    });
  });

  group('Validators.phoneCO', () {
    test('null para teléfono COL formato canónico con espacios', () {
      expect(Validators.phoneCO('+57 300 123 4567'), isNull);
    });

    test('null para teléfono COL sin espacios', () {
      expect(Validators.phoneCO('+573001234567'), isNull);
    });

    test('mensaje cuando falta el prefijo +57', () {
      expect(
        Validators.phoneCO('3001234567'),
        equals('Teléfono inválido. Usa formato +57 3XX XXX XXXX.'),
      );
    });

    test('mensaje cuando está vacío', () {
      expect(Validators.phoneCO(''), equals('Ingresa tu teléfono.'));
      expect(Validators.phoneCO(null), equals('Ingresa tu teléfono.'));
    });
  });

  group('Validators.amount', () {
    test('null para entero positivo con separadores de miles', () {
      expect(Validators.amount('100.000'), isNull);
    });

    test('null para entero positivo sin separadores', () {
      expect(Validators.amount('100000'), isNull);
    });

    test('mensaje cuando es cero', () {
      expect(
        Validators.amount('0'),
        equals('El monto debe ser mayor a cero.'),
      );
    });

    test('mensaje cuando incluye decimales', () {
      expect(
        Validators.amount('1500,50'),
        equals('El monto debe ser entero (sin decimales).'),
      );
    });

    test('mensaje cuando está vacío', () {
      expect(Validators.amount(''), equals('Ingresa un monto.'));
      expect(Validators.amount(null), equals('Ingresa un monto.'));
    });
  });
}
