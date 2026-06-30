// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'broadcast_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$BroadcastState {
  bool get isCreating => throw _privateConstructorUsedError;
  String? get broadcastId => throw _privateConstructorUsedError;
  String? get streamId => throw _privateConstructorUsedError;
  String? get youtubeLink => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  /// Create a copy of BroadcastState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BroadcastStateCopyWith<BroadcastState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BroadcastStateCopyWith<$Res> {
  factory $BroadcastStateCopyWith(
    BroadcastState value,
    $Res Function(BroadcastState) then,
  ) = _$BroadcastStateCopyWithImpl<$Res, BroadcastState>;
  @useResult
  $Res call({
    bool isCreating,
    String? broadcastId,
    String? streamId,
    String? youtubeLink,
    String? error,
  });
}

/// @nodoc
class _$BroadcastStateCopyWithImpl<$Res, $Val extends BroadcastState>
    implements $BroadcastStateCopyWith<$Res> {
  _$BroadcastStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BroadcastState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isCreating = null,
    Object? broadcastId = freezed,
    Object? streamId = freezed,
    Object? youtubeLink = freezed,
    Object? error = freezed,
  }) {
    return _then(
      _value.copyWith(
            isCreating: null == isCreating
                ? _value.isCreating
                : isCreating // ignore: cast_nullable_to_non_nullable
                      as bool,
            broadcastId: freezed == broadcastId
                ? _value.broadcastId
                : broadcastId // ignore: cast_nullable_to_non_nullable
                      as String?,
            streamId: freezed == streamId
                ? _value.streamId
                : streamId // ignore: cast_nullable_to_non_nullable
                      as String?,
            youtubeLink: freezed == youtubeLink
                ? _value.youtubeLink
                : youtubeLink // ignore: cast_nullable_to_non_nullable
                      as String?,
            error: freezed == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BroadcastStateImplCopyWith<$Res>
    implements $BroadcastStateCopyWith<$Res> {
  factory _$$BroadcastStateImplCopyWith(
    _$BroadcastStateImpl value,
    $Res Function(_$BroadcastStateImpl) then,
  ) = __$$BroadcastStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool isCreating,
    String? broadcastId,
    String? streamId,
    String? youtubeLink,
    String? error,
  });
}

/// @nodoc
class __$$BroadcastStateImplCopyWithImpl<$Res>
    extends _$BroadcastStateCopyWithImpl<$Res, _$BroadcastStateImpl>
    implements _$$BroadcastStateImplCopyWith<$Res> {
  __$$BroadcastStateImplCopyWithImpl(
    _$BroadcastStateImpl _value,
    $Res Function(_$BroadcastStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BroadcastState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isCreating = null,
    Object? broadcastId = freezed,
    Object? streamId = freezed,
    Object? youtubeLink = freezed,
    Object? error = freezed,
  }) {
    return _then(
      _$BroadcastStateImpl(
        isCreating: null == isCreating
            ? _value.isCreating
            : isCreating // ignore: cast_nullable_to_non_nullable
                  as bool,
        broadcastId: freezed == broadcastId
            ? _value.broadcastId
            : broadcastId // ignore: cast_nullable_to_non_nullable
                  as String?,
        streamId: freezed == streamId
            ? _value.streamId
            : streamId // ignore: cast_nullable_to_non_nullable
                  as String?,
        youtubeLink: freezed == youtubeLink
            ? _value.youtubeLink
            : youtubeLink // ignore: cast_nullable_to_non_nullable
                  as String?,
        error: freezed == error
            ? _value.error
            : error // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$BroadcastStateImpl implements _BroadcastState {
  const _$BroadcastStateImpl({
    this.isCreating = false,
    this.broadcastId,
    this.streamId,
    this.youtubeLink,
    this.error,
  });

  @override
  @JsonKey()
  final bool isCreating;
  @override
  final String? broadcastId;
  @override
  final String? streamId;
  @override
  final String? youtubeLink;
  @override
  final String? error;

  @override
  String toString() {
    return 'BroadcastState(isCreating: $isCreating, broadcastId: $broadcastId, streamId: $streamId, youtubeLink: $youtubeLink, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BroadcastStateImpl &&
            (identical(other.isCreating, isCreating) ||
                other.isCreating == isCreating) &&
            (identical(other.broadcastId, broadcastId) ||
                other.broadcastId == broadcastId) &&
            (identical(other.streamId, streamId) ||
                other.streamId == streamId) &&
            (identical(other.youtubeLink, youtubeLink) ||
                other.youtubeLink == youtubeLink) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    isCreating,
    broadcastId,
    streamId,
    youtubeLink,
    error,
  );

  /// Create a copy of BroadcastState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BroadcastStateImplCopyWith<_$BroadcastStateImpl> get copyWith =>
      __$$BroadcastStateImplCopyWithImpl<_$BroadcastStateImpl>(
        this,
        _$identity,
      );
}

abstract class _BroadcastState implements BroadcastState {
  const factory _BroadcastState({
    final bool isCreating,
    final String? broadcastId,
    final String? streamId,
    final String? youtubeLink,
    final String? error,
  }) = _$BroadcastStateImpl;

  @override
  bool get isCreating;
  @override
  String? get broadcastId;
  @override
  String? get streamId;
  @override
  String? get youtubeLink;
  @override
  String? get error;

  /// Create a copy of BroadcastState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BroadcastStateImplCopyWith<_$BroadcastStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
