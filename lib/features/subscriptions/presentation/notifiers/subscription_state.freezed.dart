// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'subscription_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$SubscriptionState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function() loading,
    required TResult Function(Subscription subscription) success,
    required TResult Function() cancelled,
    required TResult Function(String message) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function()? loading,
    TResult? Function(Subscription subscription)? success,
    TResult? Function()? cancelled,
    TResult? Function(String message)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function()? loading,
    TResult Function(Subscription subscription)? success,
    TResult Function()? cancelled,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SubscriptionIdle value) idle,
    required TResult Function(SubscriptionLoading value) loading,
    required TResult Function(SubscriptionSuccess value) success,
    required TResult Function(SubscriptionCancelled value) cancelled,
    required TResult Function(SubscriptionError value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SubscriptionIdle value)? idle,
    TResult? Function(SubscriptionLoading value)? loading,
    TResult? Function(SubscriptionSuccess value)? success,
    TResult? Function(SubscriptionCancelled value)? cancelled,
    TResult? Function(SubscriptionError value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SubscriptionIdle value)? idle,
    TResult Function(SubscriptionLoading value)? loading,
    TResult Function(SubscriptionSuccess value)? success,
    TResult Function(SubscriptionCancelled value)? cancelled,
    TResult Function(SubscriptionError value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubscriptionStateCopyWith<$Res> {
  factory $SubscriptionStateCopyWith(
          SubscriptionState value, $Res Function(SubscriptionState) then) =
      _$SubscriptionStateCopyWithImpl<$Res, SubscriptionState>;
}

/// @nodoc
class _$SubscriptionStateCopyWithImpl<$Res, $Val extends SubscriptionState>
    implements $SubscriptionStateCopyWith<$Res> {
  _$SubscriptionStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SubscriptionState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$SubscriptionIdleImplCopyWith<$Res> {
  factory _$$SubscriptionIdleImplCopyWith(_$SubscriptionIdleImpl value,
          $Res Function(_$SubscriptionIdleImpl) then) =
      __$$SubscriptionIdleImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$SubscriptionIdleImplCopyWithImpl<$Res>
    extends _$SubscriptionStateCopyWithImpl<$Res, _$SubscriptionIdleImpl>
    implements _$$SubscriptionIdleImplCopyWith<$Res> {
  __$$SubscriptionIdleImplCopyWithImpl(_$SubscriptionIdleImpl _value,
      $Res Function(_$SubscriptionIdleImpl) _then)
      : super(_value, _then);

  /// Create a copy of SubscriptionState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$SubscriptionIdleImpl implements SubscriptionIdle {
  const _$SubscriptionIdleImpl();

  @override
  String toString() {
    return 'SubscriptionState.idle()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$SubscriptionIdleImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function() loading,
    required TResult Function(Subscription subscription) success,
    required TResult Function() cancelled,
    required TResult Function(String message) error,
  }) {
    return idle();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function()? loading,
    TResult? Function(Subscription subscription)? success,
    TResult? Function()? cancelled,
    TResult? Function(String message)? error,
  }) {
    return idle?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function()? loading,
    TResult Function(Subscription subscription)? success,
    TResult Function()? cancelled,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (idle != null) {
      return idle();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SubscriptionIdle value) idle,
    required TResult Function(SubscriptionLoading value) loading,
    required TResult Function(SubscriptionSuccess value) success,
    required TResult Function(SubscriptionCancelled value) cancelled,
    required TResult Function(SubscriptionError value) error,
  }) {
    return idle(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SubscriptionIdle value)? idle,
    TResult? Function(SubscriptionLoading value)? loading,
    TResult? Function(SubscriptionSuccess value)? success,
    TResult? Function(SubscriptionCancelled value)? cancelled,
    TResult? Function(SubscriptionError value)? error,
  }) {
    return idle?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SubscriptionIdle value)? idle,
    TResult Function(SubscriptionLoading value)? loading,
    TResult Function(SubscriptionSuccess value)? success,
    TResult Function(SubscriptionCancelled value)? cancelled,
    TResult Function(SubscriptionError value)? error,
    required TResult orElse(),
  }) {
    if (idle != null) {
      return idle(this);
    }
    return orElse();
  }
}

abstract class SubscriptionIdle implements SubscriptionState {
  const factory SubscriptionIdle() = _$SubscriptionIdleImpl;
}

/// @nodoc
abstract class _$$SubscriptionLoadingImplCopyWith<$Res> {
  factory _$$SubscriptionLoadingImplCopyWith(_$SubscriptionLoadingImpl value,
          $Res Function(_$SubscriptionLoadingImpl) then) =
      __$$SubscriptionLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$SubscriptionLoadingImplCopyWithImpl<$Res>
    extends _$SubscriptionStateCopyWithImpl<$Res, _$SubscriptionLoadingImpl>
    implements _$$SubscriptionLoadingImplCopyWith<$Res> {
  __$$SubscriptionLoadingImplCopyWithImpl(_$SubscriptionLoadingImpl _value,
      $Res Function(_$SubscriptionLoadingImpl) _then)
      : super(_value, _then);

  /// Create a copy of SubscriptionState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$SubscriptionLoadingImpl implements SubscriptionLoading {
  const _$SubscriptionLoadingImpl();

  @override
  String toString() {
    return 'SubscriptionState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubscriptionLoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function() loading,
    required TResult Function(Subscription subscription) success,
    required TResult Function() cancelled,
    required TResult Function(String message) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function()? loading,
    TResult? Function(Subscription subscription)? success,
    TResult? Function()? cancelled,
    TResult? Function(String message)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function()? loading,
    TResult Function(Subscription subscription)? success,
    TResult Function()? cancelled,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SubscriptionIdle value) idle,
    required TResult Function(SubscriptionLoading value) loading,
    required TResult Function(SubscriptionSuccess value) success,
    required TResult Function(SubscriptionCancelled value) cancelled,
    required TResult Function(SubscriptionError value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SubscriptionIdle value)? idle,
    TResult? Function(SubscriptionLoading value)? loading,
    TResult? Function(SubscriptionSuccess value)? success,
    TResult? Function(SubscriptionCancelled value)? cancelled,
    TResult? Function(SubscriptionError value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SubscriptionIdle value)? idle,
    TResult Function(SubscriptionLoading value)? loading,
    TResult Function(SubscriptionSuccess value)? success,
    TResult Function(SubscriptionCancelled value)? cancelled,
    TResult Function(SubscriptionError value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class SubscriptionLoading implements SubscriptionState {
  const factory SubscriptionLoading() = _$SubscriptionLoadingImpl;
}

/// @nodoc
abstract class _$$SubscriptionSuccessImplCopyWith<$Res> {
  factory _$$SubscriptionSuccessImplCopyWith(_$SubscriptionSuccessImpl value,
          $Res Function(_$SubscriptionSuccessImpl) then) =
      __$$SubscriptionSuccessImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Subscription subscription});

  $SubscriptionCopyWith<$Res> get subscription;
}

/// @nodoc
class __$$SubscriptionSuccessImplCopyWithImpl<$Res>
    extends _$SubscriptionStateCopyWithImpl<$Res, _$SubscriptionSuccessImpl>
    implements _$$SubscriptionSuccessImplCopyWith<$Res> {
  __$$SubscriptionSuccessImplCopyWithImpl(_$SubscriptionSuccessImpl _value,
      $Res Function(_$SubscriptionSuccessImpl) _then)
      : super(_value, _then);

  /// Create a copy of SubscriptionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? subscription = null,
  }) {
    return _then(_$SubscriptionSuccessImpl(
      null == subscription
          ? _value.subscription
          : subscription // ignore: cast_nullable_to_non_nullable
              as Subscription,
    ));
  }

  /// Create a copy of SubscriptionState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SubscriptionCopyWith<$Res> get subscription {
    return $SubscriptionCopyWith<$Res>(_value.subscription, (value) {
      return _then(_value.copyWith(subscription: value));
    });
  }
}

/// @nodoc

class _$SubscriptionSuccessImpl implements SubscriptionSuccess {
  const _$SubscriptionSuccessImpl(this.subscription);

  @override
  final Subscription subscription;

  @override
  String toString() {
    return 'SubscriptionState.success(subscription: $subscription)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubscriptionSuccessImpl &&
            (identical(other.subscription, subscription) ||
                other.subscription == subscription));
  }

  @override
  int get hashCode => Object.hash(runtimeType, subscription);

  /// Create a copy of SubscriptionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SubscriptionSuccessImplCopyWith<_$SubscriptionSuccessImpl> get copyWith =>
      __$$SubscriptionSuccessImplCopyWithImpl<_$SubscriptionSuccessImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function() loading,
    required TResult Function(Subscription subscription) success,
    required TResult Function() cancelled,
    required TResult Function(String message) error,
  }) {
    return success(subscription);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function()? loading,
    TResult? Function(Subscription subscription)? success,
    TResult? Function()? cancelled,
    TResult? Function(String message)? error,
  }) {
    return success?.call(subscription);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function()? loading,
    TResult Function(Subscription subscription)? success,
    TResult Function()? cancelled,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(subscription);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SubscriptionIdle value) idle,
    required TResult Function(SubscriptionLoading value) loading,
    required TResult Function(SubscriptionSuccess value) success,
    required TResult Function(SubscriptionCancelled value) cancelled,
    required TResult Function(SubscriptionError value) error,
  }) {
    return success(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SubscriptionIdle value)? idle,
    TResult? Function(SubscriptionLoading value)? loading,
    TResult? Function(SubscriptionSuccess value)? success,
    TResult? Function(SubscriptionCancelled value)? cancelled,
    TResult? Function(SubscriptionError value)? error,
  }) {
    return success?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SubscriptionIdle value)? idle,
    TResult Function(SubscriptionLoading value)? loading,
    TResult Function(SubscriptionSuccess value)? success,
    TResult Function(SubscriptionCancelled value)? cancelled,
    TResult Function(SubscriptionError value)? error,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(this);
    }
    return orElse();
  }
}

abstract class SubscriptionSuccess implements SubscriptionState {
  const factory SubscriptionSuccess(final Subscription subscription) =
      _$SubscriptionSuccessImpl;

  Subscription get subscription;

  /// Create a copy of SubscriptionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubscriptionSuccessImplCopyWith<_$SubscriptionSuccessImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$SubscriptionCancelledImplCopyWith<$Res> {
  factory _$$SubscriptionCancelledImplCopyWith(
          _$SubscriptionCancelledImpl value,
          $Res Function(_$SubscriptionCancelledImpl) then) =
      __$$SubscriptionCancelledImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$SubscriptionCancelledImplCopyWithImpl<$Res>
    extends _$SubscriptionStateCopyWithImpl<$Res, _$SubscriptionCancelledImpl>
    implements _$$SubscriptionCancelledImplCopyWith<$Res> {
  __$$SubscriptionCancelledImplCopyWithImpl(_$SubscriptionCancelledImpl _value,
      $Res Function(_$SubscriptionCancelledImpl) _then)
      : super(_value, _then);

  /// Create a copy of SubscriptionState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$SubscriptionCancelledImpl implements SubscriptionCancelled {
  const _$SubscriptionCancelledImpl();

  @override
  String toString() {
    return 'SubscriptionState.cancelled()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubscriptionCancelledImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function() loading,
    required TResult Function(Subscription subscription) success,
    required TResult Function() cancelled,
    required TResult Function(String message) error,
  }) {
    return cancelled();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function()? loading,
    TResult? Function(Subscription subscription)? success,
    TResult? Function()? cancelled,
    TResult? Function(String message)? error,
  }) {
    return cancelled?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function()? loading,
    TResult Function(Subscription subscription)? success,
    TResult Function()? cancelled,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (cancelled != null) {
      return cancelled();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SubscriptionIdle value) idle,
    required TResult Function(SubscriptionLoading value) loading,
    required TResult Function(SubscriptionSuccess value) success,
    required TResult Function(SubscriptionCancelled value) cancelled,
    required TResult Function(SubscriptionError value) error,
  }) {
    return cancelled(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SubscriptionIdle value)? idle,
    TResult? Function(SubscriptionLoading value)? loading,
    TResult? Function(SubscriptionSuccess value)? success,
    TResult? Function(SubscriptionCancelled value)? cancelled,
    TResult? Function(SubscriptionError value)? error,
  }) {
    return cancelled?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SubscriptionIdle value)? idle,
    TResult Function(SubscriptionLoading value)? loading,
    TResult Function(SubscriptionSuccess value)? success,
    TResult Function(SubscriptionCancelled value)? cancelled,
    TResult Function(SubscriptionError value)? error,
    required TResult orElse(),
  }) {
    if (cancelled != null) {
      return cancelled(this);
    }
    return orElse();
  }
}

abstract class SubscriptionCancelled implements SubscriptionState {
  const factory SubscriptionCancelled() = _$SubscriptionCancelledImpl;
}

/// @nodoc
abstract class _$$SubscriptionErrorImplCopyWith<$Res> {
  factory _$$SubscriptionErrorImplCopyWith(_$SubscriptionErrorImpl value,
          $Res Function(_$SubscriptionErrorImpl) then) =
      __$$SubscriptionErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$SubscriptionErrorImplCopyWithImpl<$Res>
    extends _$SubscriptionStateCopyWithImpl<$Res, _$SubscriptionErrorImpl>
    implements _$$SubscriptionErrorImplCopyWith<$Res> {
  __$$SubscriptionErrorImplCopyWithImpl(_$SubscriptionErrorImpl _value,
      $Res Function(_$SubscriptionErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of SubscriptionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_$SubscriptionErrorImpl(
      null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$SubscriptionErrorImpl implements SubscriptionError {
  const _$SubscriptionErrorImpl(this.message);

  @override
  final String message;

  @override
  String toString() {
    return 'SubscriptionState.error(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubscriptionErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of SubscriptionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SubscriptionErrorImplCopyWith<_$SubscriptionErrorImpl> get copyWith =>
      __$$SubscriptionErrorImplCopyWithImpl<_$SubscriptionErrorImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function() loading,
    required TResult Function(Subscription subscription) success,
    required TResult Function() cancelled,
    required TResult Function(String message) error,
  }) {
    return error(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function()? loading,
    TResult? Function(Subscription subscription)? success,
    TResult? Function()? cancelled,
    TResult? Function(String message)? error,
  }) {
    return error?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function()? loading,
    TResult Function(Subscription subscription)? success,
    TResult Function()? cancelled,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SubscriptionIdle value) idle,
    required TResult Function(SubscriptionLoading value) loading,
    required TResult Function(SubscriptionSuccess value) success,
    required TResult Function(SubscriptionCancelled value) cancelled,
    required TResult Function(SubscriptionError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SubscriptionIdle value)? idle,
    TResult? Function(SubscriptionLoading value)? loading,
    TResult? Function(SubscriptionSuccess value)? success,
    TResult? Function(SubscriptionCancelled value)? cancelled,
    TResult? Function(SubscriptionError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SubscriptionIdle value)? idle,
    TResult Function(SubscriptionLoading value)? loading,
    TResult Function(SubscriptionSuccess value)? success,
    TResult Function(SubscriptionCancelled value)? cancelled,
    TResult Function(SubscriptionError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class SubscriptionError implements SubscriptionState {
  const factory SubscriptionError(final String message) =
      _$SubscriptionErrorImpl;

  String get message;

  /// Create a copy of SubscriptionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubscriptionErrorImplCopyWith<_$SubscriptionErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
