// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'preview_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$PreviewState {
  bool get isActive => throw _privateConstructorUsedError;
  bool get isStarting => throw _privateConstructorUsedError;
  String get selectedResolution => throw _privateConstructorUsedError;
  int get selectedWidth => throw _privateConstructorUsedError;
  int get selectedHeight => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  /// Create a copy of PreviewState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PreviewStateCopyWith<PreviewState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PreviewStateCopyWith<$Res> {
  factory $PreviewStateCopyWith(
    PreviewState value,
    $Res Function(PreviewState) then,
  ) = _$PreviewStateCopyWithImpl<$Res, PreviewState>;
  @useResult
  $Res call({
    bool isActive,
    bool isStarting,
    String selectedResolution,
    int selectedWidth,
    int selectedHeight,
    String? error,
  });
}

/// @nodoc
class _$PreviewStateCopyWithImpl<$Res, $Val extends PreviewState>
    implements $PreviewStateCopyWith<$Res> {
  _$PreviewStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PreviewState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isActive = null,
    Object? isStarting = null,
    Object? selectedResolution = null,
    Object? selectedWidth = null,
    Object? selectedHeight = null,
    Object? error = freezed,
  }) {
    return _then(
      _value.copyWith(
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
            isStarting: null == isStarting
                ? _value.isStarting
                : isStarting // ignore: cast_nullable_to_non_nullable
                      as bool,
            selectedResolution: null == selectedResolution
                ? _value.selectedResolution
                : selectedResolution // ignore: cast_nullable_to_non_nullable
                      as String,
            selectedWidth: null == selectedWidth
                ? _value.selectedWidth
                : selectedWidth // ignore: cast_nullable_to_non_nullable
                      as int,
            selectedHeight: null == selectedHeight
                ? _value.selectedHeight
                : selectedHeight // ignore: cast_nullable_to_non_nullable
                      as int,
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
abstract class _$$PreviewStateImplCopyWith<$Res>
    implements $PreviewStateCopyWith<$Res> {
  factory _$$PreviewStateImplCopyWith(
    _$PreviewStateImpl value,
    $Res Function(_$PreviewStateImpl) then,
  ) = __$$PreviewStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool isActive,
    bool isStarting,
    String selectedResolution,
    int selectedWidth,
    int selectedHeight,
    String? error,
  });
}

/// @nodoc
class __$$PreviewStateImplCopyWithImpl<$Res>
    extends _$PreviewStateCopyWithImpl<$Res, _$PreviewStateImpl>
    implements _$$PreviewStateImplCopyWith<$Res> {
  __$$PreviewStateImplCopyWithImpl(
    _$PreviewStateImpl _value,
    $Res Function(_$PreviewStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PreviewState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isActive = null,
    Object? isStarting = null,
    Object? selectedResolution = null,
    Object? selectedWidth = null,
    Object? selectedHeight = null,
    Object? error = freezed,
  }) {
    return _then(
      _$PreviewStateImpl(
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
        isStarting: null == isStarting
            ? _value.isStarting
            : isStarting // ignore: cast_nullable_to_non_nullable
                  as bool,
        selectedResolution: null == selectedResolution
            ? _value.selectedResolution
            : selectedResolution // ignore: cast_nullable_to_non_nullable
                  as String,
        selectedWidth: null == selectedWidth
            ? _value.selectedWidth
            : selectedWidth // ignore: cast_nullable_to_non_nullable
                  as int,
        selectedHeight: null == selectedHeight
            ? _value.selectedHeight
            : selectedHeight // ignore: cast_nullable_to_non_nullable
                  as int,
        error: freezed == error
            ? _value.error
            : error // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$PreviewStateImpl implements _PreviewState {
  const _$PreviewStateImpl({
    this.isActive = false,
    this.isStarting = false,
    this.selectedResolution = '1080p',
    this.selectedWidth = 1920,
    this.selectedHeight = 1080,
    this.error,
  });

  @override
  @JsonKey()
  final bool isActive;
  @override
  @JsonKey()
  final bool isStarting;
  @override
  @JsonKey()
  final String selectedResolution;
  @override
  @JsonKey()
  final int selectedWidth;
  @override
  @JsonKey()
  final int selectedHeight;
  @override
  final String? error;

  @override
  String toString() {
    return 'PreviewState(isActive: $isActive, isStarting: $isStarting, selectedResolution: $selectedResolution, selectedWidth: $selectedWidth, selectedHeight: $selectedHeight, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PreviewStateImpl &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.isStarting, isStarting) ||
                other.isStarting == isStarting) &&
            (identical(other.selectedResolution, selectedResolution) ||
                other.selectedResolution == selectedResolution) &&
            (identical(other.selectedWidth, selectedWidth) ||
                other.selectedWidth == selectedWidth) &&
            (identical(other.selectedHeight, selectedHeight) ||
                other.selectedHeight == selectedHeight) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    isActive,
    isStarting,
    selectedResolution,
    selectedWidth,
    selectedHeight,
    error,
  );

  /// Create a copy of PreviewState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PreviewStateImplCopyWith<_$PreviewStateImpl> get copyWith =>
      __$$PreviewStateImplCopyWithImpl<_$PreviewStateImpl>(this, _$identity);
}

abstract class _PreviewState implements PreviewState {
  const factory _PreviewState({
    final bool isActive,
    final bool isStarting,
    final String selectedResolution,
    final int selectedWidth,
    final int selectedHeight,
    final String? error,
  }) = _$PreviewStateImpl;

  @override
  bool get isActive;
  @override
  bool get isStarting;
  @override
  String get selectedResolution;
  @override
  int get selectedWidth;
  @override
  int get selectedHeight;
  @override
  String? get error;

  /// Create a copy of PreviewState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PreviewStateImplCopyWith<_$PreviewStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
