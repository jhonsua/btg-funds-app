import 'package:dartz/dartz.dart';

import 'package:btg_funds_app/core/errors/exceptions.dart';
import 'package:btg_funds_app/core/errors/failure.dart';
import 'package:btg_funds_app/features/user/data/datasources/local_user_datasource.dart';
import 'package:btg_funds_app/features/user/domain/entities/notification_channel.dart';
import 'package:btg_funds_app/features/user/domain/entities/user_state.dart';
import 'package:btg_funds_app/features/user/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl(this._datasource);

  final LocalUserDatasource _datasource;

  @override
  Future<Either<Failure, UserState>> getUser() async {
    try {
      final user = await _datasource.getUser();
      return Right(user);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Error inesperado al leer el usuario: $e'));
    }
  }

  @override
  Future<Either<Failure, double>> getBalance() async {
    try {
      final balance = await _datasource.getBalance();
      return Right(balance);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Error inesperado al leer el saldo: $e'));
    }
  }

  @override
  Future<Either<Failure, UserState>> updateUser({
    String? email,
    String? phone,
    NotificationChannel? preferredChannel,
  }) async {
    try {
      final updated = await _datasource.setUser(
        email: email,
        phone: phone,
        preferredChannel: preferredChannel,
      );
      return Right(updated);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Error inesperado al actualizar perfil: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> setBalance(double newBalance) async {
    try {
      await _datasource.setBalance(newBalance);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Error inesperado al guardar el saldo: $e'));
    }
  }

  @override
  Future<Either<Failure, UserState>> resetToDefaults() async {
    try {
      final fresh = await _datasource.reset();
      return Right(fresh);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Error inesperado al restablecer: $e'));
    }
  }
}
