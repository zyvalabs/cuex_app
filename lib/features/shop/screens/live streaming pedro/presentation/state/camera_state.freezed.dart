// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'camera_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$CameraState {
  double get zoomLevel => throw _privateConstructorUsedError;
  bool get isAutoFocusEnabled => throw _privateConstructorUsedError;
  bool get isSwitching => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  /// Create a copy of CameraState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CameraStateCopyWith<CameraState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CameraStateCopyWith<$Res> {
  factory $CameraStateCopyWith(
    CameraState value,
    $Res Function(CameraState) then,
  ) = _$CameraStateCopyWithImpl<$Res, CameraState>;
  @useResult
  $Res call({
    double zoomLevel,
    bool isAutoFocusEnabled,
    bool isSwitching,
    String? error,
  });
}

/// @nodoc
class _$CameraStateCopyWithImpl<$Res, $Val extends CameraState>
    implements $CameraStateCopyWith<$Res> {
  _$CameraStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CameraState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? zoomLevel = null,
    Object? isAutoFocusEnabled = null,
    Object? isSwitching = null,
    Object? error = freezed,
  }) {
    return _then(
      _value.copyWith(
            zoomLevel: null == zoomLevel
                ? _value.zoomLevel
                : zoomLevel // ignore: cast_nullable_to_non_nullable
                      as double,
            isAutoFocusEnabled: null == isAutoFocusEnabled
                ? _value.isAutoFocusEnabled
                : isAutoFocusEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            isSwitching: null == isSwitching
                ? _value.isSwitching
                : isSwitching // ignore: cast_nullable_to_non_nullable
                      as bool,
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
abstract class _$$CameraStateImplCopyWith<$Res>
    implements $CameraStateCopyWith<$Res> {
  factory _$$CameraStateImplCopyWith(
    _$CameraStateImpl value,
    $Res Function(_$CameraStateImpl) then,
  ) = __$$CameraStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    double zoomLevel,
    bool isAutoFocusEnabled,
    bool isSwitching,
    String? error,
  });
}

/// @nodoc
class __$$CameraStateImplCopyWithImpl<$Res>
    extends _$CameraStateCopyWithImpl<$Res, _$CameraStateImpl>
    implements _$$CameraStateImplCopyWith<$Res> {
  __$$CameraStateImplCopyWithImpl(
    _$CameraStateImpl _value,
    $Res Function(_$CameraStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CameraState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? zoomLevel = null,
    Object? isAutoFocusEnabled = null,
    Object? isSwitching = null,
    Object? error = freezed,
  }) {
    return _then(
      _$CameraStateImpl(
        zoomLevel: null == zoomLevel
            ? _value.zoomLevel
            : zoomLevel // ignore: cast_nullable_to_non_nullable
                  as double,
        isAutoFocusEnabled: null == isAutoFocusEnabled
            ? _value.isAutoFocusEnabled
            : isAutoFocusEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        isSwitching: null == isSwitching
            ? _value.isSwitching
            : isSwitching // ignore: cast_nullable_to_non_nullable
                  as bool,
        error: freezed == error
            ? _value.error
            : error // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$CameraStateImpl implements _CameraState {
  const _$CameraStateImpl({
    this.zoomLevel = 1.0,
    this.isAutoFocusEnabled = true,
    this.isSwitching = false,
    this.error,
  });

  @override
  @JsonKey()
  final double zoomLevel;
  @override
  @JsonKey()
  final bool isAutoFocusEnabled;
  @override
  @JsonKey()
  final bool isSwitching;
  @override
  final String? error;

  @override
  String toString() {
    return 'CameraState(zoomLevel: $zoomLevel, isAutoFocusEnabled: $isAutoFocusEnabled, isSwitching: $isSwitching, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CameraStateImpl &&
            (identical(other.zoomLevel, zoomLevel) ||
                other.zoomLevel == zoomLevel) &&
            (identical(other.isAutoFocusEnabled, isAutoFocusEnabled) ||
                other.isAutoFocusEnabled == isAutoFocusEnabled) &&
            (identical(other.isSwitching, isSwitching) ||
                other.isSwitching == isSwitching) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    zoomLevel,
    isAutoFocusEnabled,
    isSwitching,
    error,
  );

  /// Create a copy of CameraState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CameraStateImplCopyWith<_$CameraStateImpl> get copyWith =>
      __$$CameraStateImplCopyWithImpl<_$CameraStateImpl>(this, _$identity);
}

abstract class _CameraState implements CameraState {
  const factory _CameraState({
    final double zoomLevel,
    final bool isAutoFocusEnabled,
    final bool isSwitching,
    final String? error,
  }) = _$CameraStateImpl;

  @override
  double get zoomLevel;
  @override
  bool get isAutoFocusEnabled;
  @override
  bool get isSwitching;
  @override
  String? get error;

  /// Create a copy of CameraState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CameraStateImplCopyWith<_$CameraStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
