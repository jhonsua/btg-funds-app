import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:btg_funds_app/features/user/domain/entities/notification_channel.dart';

part 'user_state.freezed.dart';

@freezed
class UserState with _$UserState {
  const factory UserState({
    required double balance,
    required String email,
    required String phone,
    NotificationChannel? preferredChannel,
  }) = _UserState;
}
