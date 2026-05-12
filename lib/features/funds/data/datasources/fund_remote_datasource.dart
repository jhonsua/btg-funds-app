import 'package:btg_funds_app/features/funds/data/models/fund_model.dart';

abstract class FundRemoteDatasource {
  Future<List<FundModel>> getFunds();

  /// Retorna `null` cuando el id no existe en el catálogo. La conversión a
  /// `BusinessFailure` se hace en `FundRepositoryImpl`, no en datasource.
  Future<FundModel?> getFundById(String id);
}
