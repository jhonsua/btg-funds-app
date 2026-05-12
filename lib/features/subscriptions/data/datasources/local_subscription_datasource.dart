import 'package:btg_funds_app/features/subscriptions/data/models/subscription_model.dart';

abstract class LocalSubscriptionDatasource {
  Future<List<SubscriptionModel>> getSubscriptions();
}
