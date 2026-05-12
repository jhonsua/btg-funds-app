import 'package:dartz/dartz.dart';

import 'package:btg_funds_app/core/errors/failure.dart';
import 'package:btg_funds_app/core/utils/validators.dart';
import 'package:btg_funds_app/features/user/domain/entities/notification_channel.dart';
import 'package:btg_funds_app/features/user/domain/entities/user_state.dart';
import 'package:btg_funds_app/features/user/domain/repositories/user_repository.dart';

class UpdateUserUseCase {
  UpdateUserUseCase(this._repository);

  final UserRepository _repository;

  Future<Either<Failure, UserState>> call({
    String? email,
    String? phone,
    NotificationChannel? preferredChannel,
  }) async {
    // Revalidación en domain: no confiamos en que la UI haya validado.
    if (email != null) {
      final emailError = Validators.email(email);
      if (emailError != null) return Left(BusinessFailure(emailError));
    }
    if (phone != null) {
      final phoneError = Validators.phoneCO(phone);
      if (phoneError != null) return Left(BusinessFailure(phoneError));
    }

    // Caso degenerado: nada para actualizar → retorna el usuario actual sin
    // tocar el repo.
    if (email == null && phone == null && preferredChannel == null) {
      return _repository.getUser();
    }

    return _repository.updateUser(
      email: email,
      phone: phone,
      preferredChannel: preferredChannel,
    );
  }
}
