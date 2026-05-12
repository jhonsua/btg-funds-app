import 'package:btg_funds_app/features/user/domain/entities/notification_channel.dart';
import 'package:btg_funds_app/features/user/domain/entities/user_state.dart';

abstract class LocalUserDatasource {
  Future<UserState> getUser();
  Future<double> getBalance();
  Future<void> setBalance(double newBalance);
  Future<UserState> setUser({
    String? email,
    String? phone,
    NotificationChannel? preferredChannel,
  });
  Future<UserState> reset();
}
