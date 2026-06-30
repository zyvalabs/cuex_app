// lib/features/streaming/domain/states/preview_state.dart

import 'package:freezed_annotation/freezed_annotation.dart';

part 'preview_state.freezed.dart';

@freezed
class PreviewState with _$PreviewState {
  const factory PreviewState({
    @Default(false) bool isActive,
    @Default(false) bool isStarting,
    @Default('1080p') String selectedResolution,
    @Default(1920) int selectedWidth,
    @Default(1080) int selectedHeight,
    String? error,
  }) = _PreviewState;
}