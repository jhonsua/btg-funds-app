import 'package:dartz/dartz.dart';

import 'package:btg_funds_app/core/errors/failure.dart';
import 'package:btg_funds_app/features/user/domain/entities/notification_channel.dart';
import 'package:btg_funds_app/features/user/domain/entities/user_state.dart';

abstract class UserRepository {
  Future<Either<Failure, UserState>> getUser();
  Future<Either<Failure, double>> getBalance();
  Future<Either<Failure, UserState>> updateUser({
    String? email,
    String? phone,
    NotificationChannel? preferredChannel,
  });
  Future<Either<Failure, void>> setBalance(double newBalance);
  Future<Either<Failure, UserState>> resetToDefaults();
}
