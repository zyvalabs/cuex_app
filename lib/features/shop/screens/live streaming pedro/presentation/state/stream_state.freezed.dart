// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'stream_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$StreamState {
  bool get isStreaming => throw _privateConstructorUsedError;
  bool get isStarting => throw _privateConstructorUsedError;
  bool get isStopping => throw _privateConstructorUsedError;
  ConnectionStatus get connectionStatus => throw _privateConstructorUsedError;
  int get reconnectAttempts => throw _privateConstructorUsedError;
  int get maxReconnectAttempts => throw _privateConstructorUsedError;
  bool get autoReconnectEnabled => throw _privateConstructorUsedError;
  StreamHealth? get streamHealth => throw _privateConstructorUsedError;
  String? get rtmpUrl => throw _privateConstructorUsedError;
  String? get streamKey => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  /// Create a copy of StreamState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StreamStateCopyWith<StreamState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StreamStateCopyWith<$Res> {
  factory $StreamStateCopyWith(
    StreamState value,
    $Res Function(StreamState) then,
  ) = _$StreamStateCopyWithImpl<$Res, StreamState>;
  @useResult
  $Res call({
    bool isStreaming,
    bool isStarting,
    bool isStopping,
    ConnectionStatus connectionStatus,
    int reconnectAttempts,
    int maxReconnectAttempts,
    bool autoReconnectEnabled,
    StreamHealth? streamHealth,
    String? rtmpUrl,
    String? streamKey,
    String? error,
  });
}

/// @nodoc
class _$StreamStateCopyWithImpl<$Res, $Val extends StreamState>
    implements $StreamStateCopyWith<$Res> {
  _$StreamStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StreamState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isStreaming = null,
    Object? isStarting = null,
    Object? isStopping = null,
    Object? connectionStatus = null,
    Object? reconnectAttempts = null,
    Object? maxReconnectAttempts = null,
    Object? autoReconnectEnabled = null,
    Object? streamHealth = freezed,
    Object? rtmpUrl = freezed,
    Object? streamKey = freezed,
    Object? error = freezed,
  }) {
    return _then(
      _value.copyWith(
            isStreaming: null == isStreaming
                ? _value.isStreaming
                : isStreaming // ignore: cast_nullable_to_non_nullable
                      as bool,
            isStarting: null == isStarting
                ? _value.isStarting
                : isStarting // ignore: cast_nullable_to_non_nullable
                      as bool,
            isStopping: null == isStopping
                ? _value.isStopping
                : isStopping // ignore: cast_nullable_to_non_nullable
                      as bool,
            connectionStatus: null == connectionStatus
                ? _value.connectionStatus
                : connectionStatus // ignore: cast_nullable_to_non_nullable
                      as ConnectionStatus,
            reconnectAttempts: null == reconnectAttempts
                ? _value.reconnectAttempts
                : reconnectAttempts // ignore: cast_nullable_to_non_nullable
                      as int,
            maxReconnectAttempts: null == maxReconnectAttempts
                ? _value.maxReconnectAttempts
                : maxReconnectAttempts // ignore: cast_nullable_to_non_nullable
                      as int,
            autoReconnectEnabled: null == autoReconnectEnabled
                ? _value.autoReconnectEnabled
                : autoReconnectEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            streamHealth: freezed == streamHealth
                ? _value.streamHealth
                : streamHealth // ignore: cast_nullable_to_non_nullable
                      as StreamHealth?,
            rtmpUrl: freezed == rtmpUrl
                ? _value.rtmpUrl
                : rtmpUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            streamKey: freezed == streamKey
                ? _value.streamKey
                : streamKey // ignore: cast_nullable_to_non_nullable
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
abstract class _$$StreamStateImplCopyWith<$Res>
    implements $StreamStateCopyWith<$Res> {
  factory _$$StreamStateImplCopyWith(
    _$StreamStateImpl value,
    $Res Function(_$StreamStateImpl) then,
  ) = __$$StreamStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool isStreaming,
    bool isStarting,
    bool isStopping,
    ConnectionStatus connectionStatus,
    int reconnectAttempts,
    int maxReconnectAttempts,
    bool autoReconnectEnabled,
    StreamHealth? streamHealth,
    String? rtmpUrl,
    String? streamKey,
    String? error,
  });
}

/// @nodoc
class __$$StreamStateImplCopyWithImpl<$Res>
    extends _$StreamStateCopyWithImpl<$Res, _$StreamStateImpl>
    implements _$$StreamStateImplCopyWith<$Res> {
  __$$StreamStateImplCopyWithImpl(
    _$StreamStateImpl _value,
    $Res Function(_$StreamStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StreamState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isStreaming = null,
    Object? isStarting = null,
    Object? isStopping = null,
    Object? connectionStatus = null,
    Object? reconnectAttempts = null,
    Object? maxReconnectAttempts = null,
    Object? autoReconnectEnabled = null,
    Object? streamHealth = freezed,
    Object? rtmpUrl = freezed,
    Object? streamKey = freezed,
    Object? error = freezed,
  }) {
    return _then(
      _$StreamStateImpl(
        isStreaming: null == isStreaming
            ? _value.isStreaming
            : isStreaming // ignore: cast_nullable_to_non_nullable
                  as bool,
        isStarting: null == isStarting
            ? _value.isStarting
            : isStarting // ignore: cast_nullable_to_non_nullable
                  as bool,
        isStopping: null == isStopping
            ? _value.isStopping
            : isStopping // ignore: cast_nullable_to_non_nullable
                  as bool,
        connectionStatus: null == connectionStatus
            ? _value.connectionStatus
            : connectionStatus // ignore: cast_nullable_to_non_nullable
                  as ConnectionStatus,
        reconnectAttempts: null == reconnectAttempts
            ? _value.reconnectAttempts
            : reconnectAttempts // ignore: cast_nullable_to_non_nullable
                  as int,
        maxReconnectAttempts: null == maxReconnectAttempts
            ? _value.maxReconnectAttempts
            : maxReconnectAttempts // ignore: cast_nullable_to_non_nullable
                  as int,
        autoReconnectEnabled: null == autoReconnectEnabled
            ? _value.autoReconnectEnabled
            : autoReconnectEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        streamHealth: freezed == streamHealth
            ? _value.streamHealth
            : streamHealth // ignore: cast_nullable_to_non_nullable
                  as StreamHealth?,
        rtmpUrl: freezed == rtmpUrl
            ? _value.rtmpUrl
            : rtmpUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        streamKey: freezed == streamKey
            ? _value.streamKey
            : streamKey // ignore: cast_nullable_to_non_nullable
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

class _$StreamStateImpl implements _StreamState {
  const _$StreamStateImpl({
    this.isStreaming = false,
    this.isStarting = false,
    this.isStopping = false,
    this.connectionStatus = ConnectionStatus.disconnected,
    this.reconnectAttempts = 0,
    this.maxReconnectAttempts = 3,
    this.autoReconnectEnabled = true,
    this.streamHealth,
    this.rtmpUrl,
    this.streamKey,
    this.error,
  });

  @override
  @JsonKey()
  final bool isStreaming;
  @override
  @JsonKey()
  final bool isStarting;
  @override
  @JsonKey()
  final bool isStopping;
  @override
  @JsonKey()
  final ConnectionStatus connectionStatus;
  @override
  @JsonKey()
  final int reconnectAttempts;
  @override
  @JsonKey()
  final int maxReconnectAttempts;
  @override
  @JsonKey()
  final bool autoReconnectEnabled;
  @override
  final StreamHealth? streamHealth;
  @override
  final String? rtmpUrl;
  @override
  final String? streamKey;
  @override
  final String? error;

  @override
  String toString() {
    return 'StreamState(isStreaming: $isStreaming, isStarting: $isStarting, isStopping: $isStopping, connectionStatus: $connectionStatus, reconnectAttempts: $reconnectAttempts, maxReconnectAttempts: $maxReconnectAttempts, autoReconnectEnabled: $autoReconnectEnabled, streamHealth: $streamHealth, rtmpUrl: $rtmpUrl, streamKey: $streamKey, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StreamStateImpl &&
            (identical(other.isStreaming, isStreaming) ||
                other.isStreaming == isStreaming) &&
            (identical(other.isStarting, isStarting) ||
                other.isStarting == isStarting) &&
            (identical(other.isStopping, isStopping) ||
                other.isStopping == isStopping) &&
            (identical(other.connectionStatus, connectionStatus) ||
                other.connectionStatus == connectionStatus) &&
            (identical(other.reconnectAttempts, reconnectAttempts) ||
                other.reconnectAttempts == reconnectAttempts) &&
            (identical(other.maxReconnectAttempts, maxReconnectAttempts) ||
                other.maxReconnectAttempts == maxReconnectAttempts) &&
            (identical(other.autoReconnectEnabled, autoReconnectEnabled) ||
                other.autoReconnectEnabled == autoReconnectEnabled) &&
            (identical(other.streamHealth, streamHealth) ||
                other.streamHealth == streamHealth) &&
            (identical(other.rtmpUrl, rtmpUrl) || other.rtmpUrl == rtmpUrl) &&
            (identical(other.streamKey, streamKey) ||
                other.streamKey == streamKey) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    isStreaming,
    isStarting,
    isStopping,
    connectionStatus,
    reconnectAttempts,
    maxReconnectAttempts,
    autoReconnectEnabled,
    streamHealth,
    rtmpUrl,
    streamKey,
    error,
  );

  /// Create a copy of StreamState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StreamStateImplCopyWith<_$StreamStateImpl> get copyWith =>
      __$$StreamStateImplCopyWithImpl<_$StreamStateImpl>(this, _$identity);
}

abstract class _StreamState implements StreamState {
  const factory _StreamState({
    final bool isStreaming,
    final bool isStarting,
    final bool isStopping,
    final ConnectionStatus connectionStatus,
    final int reconnectAttempts,
    final int maxReconnectAttempts,
    final bool autoReconnectEnabled,
    final StreamHealth? streamHealth,
    final String? rtmpUrl,
    final String? streamKey,
    final String? error,
  }) = _$StreamStateImpl;

  @override
  bool get isStreaming;
  @override
  bool get isStarting;
  @override
  bool get isStopping;
  @override
  ConnectionStatus get connectionStatus;
  @override
  int get reconnectAttempts;
  @override
  int get maxReconnectAttempts;
  @override
  bool get autoReconnectEnabled;
  @override
  StreamHealth? get streamHealth;
  @override
  String? get rtmpUrl;
  @override
  String? get streamKey;
  @override
  String? get error;

  /// Create a copy of StreamState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StreamStateImplCopyWith<_$StreamStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
