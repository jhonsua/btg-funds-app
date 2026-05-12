import 'package:dartz/dartz.dart';

import 'package:btg_funds_app/core/errors/failure.dart';
import 'package:btg_funds_app/features/subscriptions/domain/entities/subscription.dart';

/// Solo lectura. La escritura de subscriptions ocurre vía [AtomicWrite] en
/// `SubscribeToFundUseCase` y `CancelSubscriptionUseCase` para mantener la
/// atomicidad de las 3 keys críticas (balance + subscriptions + transactions).
abstract class SubscriptionRepository {
  Future<Either<Failure, List<Subscription>>> getSubscriptions();
}
