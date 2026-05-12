import 'package:dartz/dartz.dart';

import 'package:btg_funds_app/core/errors/failure.dart';
import 'package:btg_funds_app/features/funds/domain/entities/fund.dart';

abstract class FundRepository {
  Future<Either<Failure, List<Fund>>> getFunds();

  /// Retorna `Right(Fund)` cuando el id existe en el catálogo.
  ///
  /// Retorna `Left(BusinessFailure)` cuando el id no existe — "no encontrado"
  /// se modela como resultado de negocio, no como error técnico. La
  /// conversión a `BusinessFailure` se hace en `FundRepositoryImpl`, no en
  /// el datasource (que retorna `null`). Esta es una desviación consciente
  /// del patrón `Future<T>` non-null sugerido por
  /// `btg-flutter-arch §2.1` — justificada porque excepción + try/on en el
  /// repo es ruidoso para un caso normal de uso.
  Future<Either<Failure, Fund>> getFundById(String id);
}
