import 'package:dartz/dartz.dart';

import 'package:btg_funds_app/core/errors/failure.dart';
import 'package:btg_funds_app/features/user/domain/repositories/user_repository.dart';

class GetBalanceUseCase {
  GetBalanceUseCase(this._repository);

  final UserRepository _repository;

  Future<Either<Failure, double>> call() => _repository.getBalance();
}
