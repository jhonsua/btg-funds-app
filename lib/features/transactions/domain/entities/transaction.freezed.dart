// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$Transaction {
  String get id => throw _privateConstructorUsedError;
  TransactionType get type => throw _privateConstructorUsedError;
  String get fundId => throw _privateConstructorUsedError;
  String get fundName => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  NotificationChannel? get channel => throw _privateConstructorUsedError;

  /// Create a copy of Transaction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TransactionCopyWith<Transaction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TransactionCopyWith<$Res> {
  factory $TransactionCopyWith(
          Transaction value, $Res Function(Transaction) then) =
      _$TransactionCopyWithImpl<$Res, Transaction>;
  @useResult
  $Res call(
      {String id,
      TransactionType type,
      String fundId,
      String fundName,
      double amount,
      DateTime createdAt,
      NotificationChannel? channel});
}

/// @nodoc
class _$TransactionCopyWithImpl<$Res, $Val extends Transaction>
    implements $TransactionCopyWith<$Res> {
  _$TransactionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Transaction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? fundId = null,
    Object? fundName = null,
    Object? amount = null,
    Object? createdAt = null,
    Object? channel = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as TransactionType,
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
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      channel: freezed == channel
          ? _value.channel
          : channel // ignore: cast_nullable_to_non_nullable
              as NotificationChannel?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TransactionImplCopyWith<$Res>
    implements $TransactionCopyWith<$Res> {
  factory _$$TransactionImplCopyWith(
          _$TransactionImpl value, $Res Function(_$TransactionImpl) then) =
      __$$TransactionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      TransactionType type,
      String fundId,
      String fundName,
      double amount,
      DateTime createdAt,
      NotificationChannel? channel});
}

/// @nodoc
class __$$TransactionImplCopyWithImpl<$Res>
    extends _$TransactionCopyWithImpl<$Res, _$TransactionImpl>
    implements _$$TransactionImplCopyWith<$Res> {
  __$$TransactionImplCopyWithImpl(
      _$TransactionImpl _value, $Res Function(_$TransactionImpl) _then)
      : super(_value, _then);

  /// Create a copy of Transaction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? fundId = null,
    Object? fundName = null,
    Object? amount = null,
    Object? createdAt = null,
    Object? channel = freezed,
  }) {
    return _then(_$TransactionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as TransactionType,
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
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      channel: freezed == channel
          ? _value.channel
          : channel // ignore: cast_nullable_to_non_nullable
              as NotificationChannel?,
    ));
  }
}

/// @nodoc

class _$TransactionImpl implements _Transaction {
  const _$TransactionImpl(
      {required this.id,
      required this.type,
      required this.fundId,
      required this.fundName,
      required this.amount,
      required this.createdAt,
      this.channel});

  @override
  final String id;
  @override
  final TransactionType type;
  @override
  final String fundId;
  @override
  final String fundName;
  @override
  final double amount;
  @override
  final DateTime createdAt;
  @override
  final NotificationChannel? channel;

  @override
  String toString() {
    return 'Transaction(id: $id, type: $type, fundId: $fundId, fundName: $fundName, amount: $amount, createdAt: $createdAt, channel: $channel)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TransactionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.fundId, fundId) || other.fundId == fundId) &&
            (identical(other.fundName, fundName) ||
                other.fundName == fundName) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.channel, channel) || other.channel == channel));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, id, type, fundId, fundName, amount, createdAt, channel);

  /// Create a copy of Transaction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TransactionImplCopyWith<_$TransactionImpl> get copyWith =>
      __$$TransactionImplCopyWithImpl<_$TransactionImpl>(this, _$identity);
}

abstract class _Transaction implements Transaction {
  const factory _Transaction(
      {required final String id,
      required final TransactionType type,
      required final String fundId,
      required final String fundName,
      required final double amount,
      required final DateTime createdAt,
      final NotificationChannel? channel}) = _$TransactionImpl;

  @override
  String get id;
  @override
  TransactionType get type;
  @override
  String get fundId;
  @override
  String get fundName;
  @override
  double get amount;
  @override
  DateTime get createdAt;
  @override
  NotificationChannel? get channel;

  /// Create a copy of Transaction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TransactionImplCopyWith<_$TransactionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
