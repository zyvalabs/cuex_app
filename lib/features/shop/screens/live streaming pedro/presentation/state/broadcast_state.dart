// lib/features/streaming/domain/states/broadcast_state.dart

import 'package:freezed_annotation/freezed_annotation.dart';

part 'broadcast_state.freezed.dart';

@freezed
class BroadcastState with _$BroadcastState {
  const factory BroadcastState({
    @Default(false) bool isCreating,
    String? broadcastId,
    String? streamId,
    String? youtubeLink,
    String? error,
  }) = _BroadcastState;
}