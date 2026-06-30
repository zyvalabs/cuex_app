// lib/features/streaming/domain/states/audio_state.dart

import 'package:freezed_annotation/freezed_annotation.dart';

part 'audio_state.freezed.dart';

@freezed
class AudioState with _$AudioState {
  const factory AudioState({
    @Default(false) bool isMuted,
    @Default(false) bool isToggling,
    String? error,
  }) = _AudioState;
}