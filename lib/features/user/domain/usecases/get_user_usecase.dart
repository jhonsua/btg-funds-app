import 'package:dartz/dartz.dart';

import 'package:btg_funds_app/core/errors/failure.dart';
import 'package:btg_funds_app/features/user/domain/entities/user_state.dart';
import 'package:btg_funds_app/features/user/domain/repositories/user_repository.dart';

class GetUserUseCase {
  GetUserUseCase(this._repository);

  final UserRepository _repository;

  Future<Either<Failure, UserState>> call() => _repository.getUser();
}
