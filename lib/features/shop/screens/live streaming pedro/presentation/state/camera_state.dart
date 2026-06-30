// lib/features/streaming/domain/states/camera_state.dart

import 'package:freezed_annotation/freezed_annotation.dart';

part 'camera_state.freezed.dart';

@freezed
class CameraState with _$CameraState {
  const factory CameraState({
    @Default(1.0) double zoomLevel,
    @Default(true) bool isAutoFocusEnabled,
    @Default(false) bool isSwitching,
    String? error,
  }) = _CameraState;
}