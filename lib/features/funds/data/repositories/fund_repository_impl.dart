import 'package:dartz/dartz.dart';

import 'package:btg_funds_app/core/errors/exceptions.dart';
import 'package:btg_funds_app/core/errors/failure.dart';
import 'package:btg_funds_app/features/funds/data/datasources/fund_remote_datasource.dart';
import 'package:btg_funds_app/features/funds/domain/entities/fund.dart';
import 'package:btg_funds_app/features/funds/domain/repositories/fund_repository.dart';

class FundRepositoryImpl implements FundRepository {
  FundRepositoryImpl(this._datasource);

  final FundRemoteDatasource _datasource;

  @override
  Future<Either<Failure, List<Fund>>> getFunds() async {
    try {
      final models = await _datasource.getFunds();
      return Right(models.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado al obtener fondos: $e'));
    }
  }

  @override
  Future<Either<Failure, Fund>> getFundById(String id) async {
    try {
      final model = await _datasource.getFundById(id);
      if (model == null) {
        return const Left(BusinessFailure('Fondo no disponible.'));
      }
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado al obtener el fondo: $e'));
    }
  }
}
