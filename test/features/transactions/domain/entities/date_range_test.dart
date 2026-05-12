import 'package:flutter_test/flutter_test.dart';

import 'package:btg_funds_app/features/transactions/domain/entities/date_range.dart';

void main() {
  final start = DateTime.utc(2026, 5);
  final end = DateTime.utc(2026, 5, 12);
  final range = DateRange(start: start, end: end);

  group('DateRange.contains', () {
    test('retorna true para una fecha en el medio del rango', () {
      expect(range.contains(DateTime.utc(2026, 5, 6)), isTrue);
    });

    test('retorna false para fechas fuera del rango', () {
      expect(range.contains(DateTime.utc(2026, 4, 30)), isFalse);
      expect(range.contains(DateTime.utc(2026, 5, 13)), isFalse);
    });

    test('extremos inclusivos: start y end exactos cuentan como dentro', () {
      expect(range.contains(start), isTrue);
      expect(range.contains(end), isTrue);
    });
  });
}
