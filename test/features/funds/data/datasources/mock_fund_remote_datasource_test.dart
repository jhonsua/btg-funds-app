import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:btg_funds_app/core/errors/exceptions.dart';
import 'package:btg_funds_app/features/funds/data/datasources/mock_fund_remote_datasource.dart';
import 'package:btg_funds_app/features/funds/domain/entities/fund_category.dart';

import '../../../../helpers/test_asset_bundle.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const tFundsJson = '''
  [
    {"id":"a","name":"Fondo A","minimum_amount":1000,"category":"fpv","description":"desc A"},
    {"id":"b","name":"Fondo B","minimum_amount":2000,"category":"fic"}
  ]
  ''';

  group('MockFundRemoteDatasource — JSON sintético', () {
    test('getFunds carga y parsea los fondos del bundle', () async {
      final ds = MockFundRemoteDatasource(
        bundle: TestAssetBundle({'assets/mocks/funds.json': tFundsJson}),
      );

      final funds = await ds.getFunds();

      expect(funds.length, equals(2));
      expect(funds[0].id, equals('a'));
      expect(funds[0].description, equals('desc A'));
      expect(funds[1].category, equals(FundCategory.fic));
      expect(funds[1].description, equals(''));
    });

    test('asset path inexistente lanza ServerException', () async {
      final ds = MockFundRemoteDatasource(
        bundle: TestAssetBundle(const {}),
      );

      await expectLater(
        ds.getFunds(),
        throwsA(isA<ServerException>()),
      );
    });

    test('JSON malformado (no es array) lanza ServerException', () async {
      final ds = MockFundRemoteDatasource(
        bundle: TestAssetBundle({
          'assets/mocks/funds.json': '{"id":"x","name":"un objeto, no array"}',
        }),
      );

      await expectLater(
        ds.getFunds(),
        throwsA(
          isA<ServerException>().having(
            (e) => e.message,
            'message',
            contains('array'),
          ),
        ),
      );
    });

    test(
      'getFundById retorna el modelo cuando existe y null cuando no existe',
      () async {
        final ds = MockFundRemoteDatasource(
          bundle: TestAssetBundle({'assets/mocks/funds.json': tFundsJson}),
        );

        final encontrado = await ds.getFundById('a');
        final inexistente = await ds.getFundById('xyz');

        expect(encontrado, isNotNull);
        expect(encontrado!.id, equals('a'));
        expect(inexistente, isNull);
      },
    );
  });

  group('MockFundRemoteDatasource — catálogo canónico (rootBundle real)', () {
    test(
      'assets/mocks/funds.json contiene los 5 fondos del SPEC_FUNCIONAL §2',
      () async {
        final ds = MockFundRemoteDatasource(bundle: rootBundle);

        final funds = await ds.getFunds();

        expect(funds.length, equals(5));
        expect(
          funds.map((f) => f.id).toSet(),
          equals({'1', '2', '3', '4', '5'}),
        );

        final byId = {for (final f in funds) f.id: f};
        expect(byId['1']!.minimumAmount, equals(75000));
        expect(byId['1']!.category, equals(FundCategory.fpv));
        expect(byId['2']!.minimumAmount, equals(125000));
        expect(byId['2']!.category, equals(FundCategory.fpv));
        expect(byId['3']!.minimumAmount, equals(50000));
        expect(byId['3']!.category, equals(FundCategory.fic));
        expect(byId['4']!.minimumAmount, equals(250000));
        expect(byId['4']!.category, equals(FundCategory.fic));
        expect(byId['5']!.minimumAmount, equals(100000));
        expect(byId['5']!.category, equals(FundCategory.fpv));
      },
    );
  });
}
