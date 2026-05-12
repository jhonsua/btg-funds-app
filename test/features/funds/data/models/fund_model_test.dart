import 'package:flutter_test/flutter_test.dart';

import 'package:btg_funds_app/core/errors/exceptions.dart';
import 'package:btg_funds_app/features/funds/data/models/fund_model.dart';
import 'package:btg_funds_app/features/funds/domain/entities/fund_category.dart';

void main() {
  group('FundModel.fromJson', () {
    test('parsea un JSON completo correctamente', () {
      final model = FundModel.fromJson(<String, dynamic>{
        'id': '1',
        'name': 'FPV_BTG_PACTUAL_RECAUDADORA',
        'minimum_amount': 75000,
        'category': 'fpv',
        'description': 'Texto descriptivo.',
      });

      expect(model.id, equals('1'));
      expect(model.name, equals('FPV_BTG_PACTUAL_RECAUDADORA'));
      expect(model.minimumAmount, equals(75000));
      expect(model.category, equals(FundCategory.fpv));
      expect(model.description, equals('Texto descriptivo.'));
    });

    test('description faltante defaultea a string vacío', () {
      final model = FundModel.fromJson(<String, dynamic>{
        'id': '3',
        'name': 'DEUDAPRIVADA',
        'minimum_amount': 50000,
        'category': 'fic',
        // description: ausente
      });

      expect(model.description, equals(''));
    });

    test('categoría desconocida o ausente defaultea a fic', () {
      final desconocida = FundModel.fromJson(<String, dynamic>{
        'id': '99',
        'name': 'X',
        'minimum_amount': 1,
        'category': 'cripto', // no matchea ningún enum value
      });
      expect(desconocida.category, equals(FundCategory.fic));

      final ausente = FundModel.fromJson(<String, dynamic>{
        'id': '100',
        'name': 'Y',
        'minimum_amount': 1,
        // category: ausente
      });
      expect(ausente.category, equals(FundCategory.fic));
    });

    test('minimum_amount faltante lanza ServerException', () {
      expect(
        () => FundModel.fromJson(<String, dynamic>{
          'id': '1',
          'name': 'Fondo',
          'category': 'fpv',
          // minimum_amount: ausente → crítico
        }),
        throwsA(
          isA<ServerException>().having(
            (e) => e.message,
            'message',
            contains('minimum_amount'),
          ),
        ),
      );
    });
  });
}
