// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'subscription.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$Subscription {
  String get id => throw _privateConstructorUsedError;
  String get fundId =>
      throw _privateConstructorUsedError; // Denormalizado para evitar joins al renderizar listas.
  String get fundName => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  DateTime get openedAt => throw _privateConstructorUsedError;
  NotificationChannel get channel => throw _privateConstructorUsedError;

  /// Create a copy of Subscription
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SubscriptionCopyWith<Subscription> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubscriptionCopyWith<$Res> {
  factory $SubscriptionCopyWith(
          Subscription value, $Res Function(Subscription) then) =
      _$SubscriptionCopyWithImpl<$Res, Subscription>;
  @useResult
  $Res call(
      {String id,
      String fundId,
      String fundName,
      double amount,
      DateTime openedAt,
      NotificationChannel channel});
}

/// @nodoc
class _$SubscriptionCopyWithImpl<$Res, $Val extends Subscription>
    implements $SubscriptionCopyWith<$Res> {
  _$SubscriptionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Subscription
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fundId = null,
    Object? fundName = null,
    Object? amount = null,
    Object? openedAt = null,
    Object? channel = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      fundId: null == fundId
          ? _value.fundId
          : fundId // ignore: cast_nullable_to_non_nullable
              as String,
      fundName: null == fundName
          ? _value.fundName
          : fundName // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      openedAt: null == openedAt
          ? _value.openedAt
          : openedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      channel: null == channel
          ? _value.channel
          : channel // ignore: cast_nullable_to_non_nullable
              as NotificationChannel,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SubscriptionImplCopyWith<$Res>
    implements $SubscriptionCopyWith<$Res> {
  factory _$$SubscriptionImplCopyWith(
          _$SubscriptionImpl value, $Res Function(_$SubscriptionImpl) then) =
      __$$SubscriptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String fundId,
      String fundName,
      double amount,
      DateTime openedAt,
      NotificationChannel channel});
}

/// @nodoc
class __$$SubscriptionImplCopyWithImpl<$Res>
    extends _$SubscriptionCopyWithImpl<$Res, _$SubscriptionImpl>
    implements _$$SubscriptionImplCopyWith<$Res> {
  __$$SubscriptionImplCopyWithImpl(
      _$SubscriptionImpl _value, $Res Function(_$SubscriptionImpl) _then)
      : super(_value, _then);

  /// Create a copy of Subscription
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fundId = null,
    Object? fundName = null,
    Object? amount = null,
    Object? openedAt = null,
    Object? channel = null,
  }) {
    return _then(_$SubscriptionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      fundId: null == fundId
          ? _value.fundId
          : fundId // ignore: cast_nullable_to_non_nullable
              as String,
      fundName: null == fundName
          ? _value.fundName
          : fundName // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      openedAt: null == openedAt
          ? _value.openedAt
          : openedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      channel: null == channel
          ? _value.channel
          : channel // ignore: cast_nullable_to_non_nullable
              as NotificationChannel,
    ));
  }
}

/// @nodoc

class _$SubscriptionImpl implements _Subscription {
  const _$SubscriptionImpl(
      {required this.id,
      required this.fundId,
      required this.fundName,
      required this.amount,
      required this.openedAt,
      required this.channel});

  @override
  final String id;
  @override
  final String fundId;
// Denormalizado para evitar joins al renderizar listas.
  @override
  final String fundName;
  @override
  final double amount;
  @override
  final DateTime openedAt;
  @override
  final NotificationChannel channel;

  @override
  String toString() {
    return 'Subscription(id: $id, fundId: $fundId, fundName: $fundName, amount: $amount, openedAt: $openedAt, channel: $channel)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubscriptionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.fundId, fundId) || other.fundId == fundId) &&
            (identical(other.fundName, fundName) ||
                other.fundName == fundName) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.openedAt, openedAt) ||
                other.openedAt == openedAt) &&
            (identical(other.channel, channel) || other.channel == channel));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, id, fundId, fundName, amount, openedAt, channel);

  /// Create a copy of Subscription
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SubscriptionImplCopyWith<_$SubscriptionImpl> get copyWith =>
      __$$SubscriptionImplCopyWithImpl<_$SubscriptionImpl>(this, _$identity);
}

abstract class _Subscription implements Subscription {
  const factory _Subscription(
      {required final String id,
      required final String fundId,
      required final String fundName,
      required final double amount,
      required final DateTime openedAt,
      required final NotificationChannel channel}) = _$SubscriptionImpl;

  @override
  String get id;
  @override
  String get fundId; // Denormalizado para evitar joins al renderizar listas.
  @override
  String get fundName;
  @override
  double get amount;
  @override
  DateTime get openedAt;
  @override
  NotificationChannel get channel;

  /// Create a copy of Subscription
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubscriptionImplCopyWith<_$SubscriptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
