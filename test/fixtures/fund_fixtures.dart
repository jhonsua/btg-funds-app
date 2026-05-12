import 'package:btg_funds_app/features/funds/domain/entities/fund.dart';
import 'package:btg_funds_app/features/funds/domain/entities/fund_category.dart';

/// Catálogo canónico de fondos según SPEC_FUNCIONAL §2. Reutilizable en tests
/// de Etapas 3-5.
class FundFixtures {
  FundFixtures._();

  static const recaudadora = Fund(
    id: '1',
    name: 'FPV_BTG_PACTUAL_RECAUDADORA',
    minimumAmount: 75000,
    category: FundCategory.fpv,
    description:
        'Fondo de pensión voluntaria con perfil conservador, enfocado en preservación del capital.',
  );

  static const ecopetrol = Fund(
    id: '2',
    name: 'FPV_BTG_PACTUAL_ECOPETROL',
    minimumAmount: 125000,
    category: FundCategory.fpv,
    description:
        'Fondo de pensión voluntaria con exposición al sector energético colombiano.',
  );

  static const deudaPrivada = Fund(
    id: '3',
    name: 'DEUDAPRIVADA',
    minimumAmount: 50000,
    category: FundCategory.fic,
    description:
        'Fondo de inversión colectiva en deuda privada corporativa de empresas colombianas.',
  );

  static const accionesFondo = Fund(
    id: '4',
    name: 'FDO-ACCIONES',
    minimumAmount: 250000,
    category: FundCategory.fic,
    description:
        'Fondo de inversión colectiva con exposición a renta variable colombiana.',
  );

  static const dinamica = Fund(
    id: '5',
    name: 'FPV_BTG_PACTUAL_DINAMICA',
    minimumAmount: 100000,
    category: FundCategory.fpv,
    description:
        'Fondo de pensión voluntaria con perfil dinámico, balance entre renta fija y variable.',
  );

  static const all = <Fund>[
    recaudadora,
    ecopetrol,
    deudaPrivada,
    accionesFondo,
    dinamica,
  ];
}
