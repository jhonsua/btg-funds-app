import 'package:dartz/dartz.dart';

import 'package:btg_funds_app/core/errors/failure.dart';
import 'package:btg_funds_app/features/funds/domain/entities/fund.dart';
import 'package:btg_funds_app/features/funds/domain/repositories/fund_repository.dart';

class GetFundsUseCase {
  GetFundsUseCase(this._repository);

  final FundRepository _repository;

  Future<Either<Failure, List<Fund>>> call() => _repository.getFunds();
}
