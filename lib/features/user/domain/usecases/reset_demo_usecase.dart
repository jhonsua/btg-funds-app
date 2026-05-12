import 'package:dartz/dartz.dart';

import 'package:btg_funds_app/core/errors/failure.dart';
import 'package:btg_funds_app/features/user/domain/entities/user_state.dart';
import 'package:btg_funds_app/features/user/domain/repositories/user_repository.dart';

class ResetDemoUseCase {
  ResetDemoUseCase(this._repository);

  final UserRepository _repository;

  Future<Either<Failure, UserState>> call() async {
    // TODO Etapa 4: validar que no haya operaciones pendientes en
    //   SubscriptionNotifier o TransactionsNotifier (SPEC_FUNCIONAL §7).
    //   Cuando existan esos notifiers, inyectarlos aquí y retornar
    //   BusinessFailure('Espera a que termine la operación actual.')
    //   si alguno está en AsyncLoading.
    return _repository.resetToDefaults();
  }
}
