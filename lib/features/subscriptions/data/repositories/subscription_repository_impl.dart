import 'package:dartz/dartz.dart';

import 'package:btg_funds_app/core/errors/exceptions.dart';
import 'package:btg_funds_app/core/errors/failure.dart';
import 'package:btg_funds_app/features/subscriptions/data/datasources/local_subscription_datasource.dart';
import 'package:btg_funds_app/features/subscriptions/domain/entities/subscription.dart';
import 'package:btg_funds_app/features/subscriptions/domain/repositories/subscription_repository.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  SubscriptionRepositoryImpl(this._datasource);

  final LocalSubscriptionDatasource _datasource;

  @override
  Future<Either<Failure, List<Subscription>>> getSubscriptions() async {
    try {
      final models = await _datasource.getSubscriptions();
      return Right(models.map((m) => m.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Error inesperado: $e'));
    }
  }
}
