import 'package:dartz/dartz.dart';

import 'package:btg_funds_app/core/errors/failure.dart';
import 'package:btg_funds_app/features/user/domain/entities/user_state.dart';
import 'package:btg_funds_app/features/user/domain/repositories/user_repository.dart';

class ResetDemoUseCase {
  ResetDemoUseCase(this._repository);

  final UserRepository _repository;

  Future<Either<Failure, UserState>> call() async {
    // TODO Etapa futura: validar OperationLockRepository cross-feature
    // (SPEC_FUNCIONAL §7). La UI (ProfileScreen, Etapa 6) mitiga
    // parcialmente deshabilitando el botón "Restablecer" cuando hay
    // SubscriptionLoading activo, pero un lock real cubriría también
    // cancelaciones, transactions y futuras operaciones async.
    return _repository.resetToDefaults();
  }
}
