import 'package:dartz/dartz.dart';

import 'package:btg_funds_app/core/errors/failure.dart';
import 'package:btg_funds_app/features/subscriptions/domain/entities/subscription.dart';
import 'package:btg_funds_app/features/subscriptions/domain/repositories/subscription_repository.dart';

class GetSubscriptionsUseCase {
  GetSubscriptionsUseCase(this._repository);

  final SubscriptionRepository _repository;

  Future<Either<Failure, List<Subscription>>> call() =>
      _repository.getSubscriptions();
}
