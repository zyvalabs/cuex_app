import 'dart:async';
import 'package:cuex_app/controllers/score%20sync/sync_mode_contoller.dart';
import 'package:get/get.dart';

import '../../repositories/local/score_local_storage_service.dart';
import '../../screens/live streaming/widgets/match_data_builder.dart';
import '../../services/rtdb_sync_service.dart';
import '../camera/camera_stream_controller.dart';
import '../frame_tracking_controller.dart';
import '../match_result_conrollers.dart';
import '../score_controller.dart';


/// Owns all save/load/sync orchestration for a scoring session — pure
/// logic, no UI. ScoringScreen just calls loadForMatch() once and
/// persist() after any user action; this controller handles the rest
/// (local storage + pushing through whichever sync transport is active).
///
/// Also handles the "second device" case — if THIS device is scoring
/// the match, local storage is the source of truth. If it's a different
/// device (or same account, different phone) with no local data for this
/// matchId, it falls back to fetching the latest state from RTDB, and
/// stays live-subscribed so it keeps updating as the scorer's device
/// pushes changes — e.g. the streaming phone or someone just viewing.
class ScoringPersistenceController extends GetxController {
  final ScoreController score = Get.isRegistered<ScoreController>() ? Get.find<ScoreController>() : Get.put(ScoreController());
  final FrameTrackingController frames = Get.isRegistered<FrameTrackingController>()
      ? Get.find<FrameTrackingController>()
      : Get.put(FrameTrackingController());
  final MatchResultController result = Get.isRegistered<MatchResultController>()
      ? Get.find<MatchResultController>()
      : Get.put(MatchResultController());
  final SyncModeController syncMode =
  Get.isRegistered<SyncModeController>() ? Get.find<SyncModeController>() : Get.put(SyncModeController());

  final ScoreLocalStorageService _storage = ScoreLocalStorageService();
  final RtdbSyncService _rtdb = RtdbSyncService();

  String? _matchId;
  StreamSubscription? _remoteSubscription;

  // Scoreboard context — set once via setScoreboardContext(), used to
  // build the correct matchData shape whenever persist() is called.
  String? _side1Name;
  String? _side2Name;
  String? _eventName;
  String? _roundName;
  int _totalFrames = 5;

  /// Call once (e.g. from ScoringScreen's initState) so persist() can
  /// push live scoreboard updates to the streaming device whenever
  /// score/frame state changes — without ScoringScreen needing to call
  /// updateScoreboard() manually after every single action.
  void setScoreboardContext({
    required String side1Name,
    required String side2Name,
    required String eventName,
    required String roundName,
    required int totalFrames,
  }) {
    _side1Name = side1Name;
    _side2Name = side2Name;
    _eventName = eventName;
    _roundName = roundName;
    _totalFrames = totalFrames;
  }

  /// Call once when ScoringScreen opens.
  /// 1. Tries local storage first (this device's own saved session).
  /// 2. If nothing local, fetches once from RTDB (another device may
  ///    have already scored this match).
  /// 3. Starts a live RTDB listener regardless, so this device keeps
  ///    receiving updates if a DIFFERENT device is the one actively
  ///    scoring (e.g. this is just a viewing device).
  Future<void> loadForMatch(String matchId) async {
    _matchId = matchId;

    final localJson = await _storage.loadRaw(matchId);
    if (localJson != null) {
      // ignore: avoid_print
      print('🟢 [ScoringPersistenceController] Loaded from LOCAL storage for $matchId');
      ScoreLocalStorageService.applyJsonToControllers(localJson, score: score, frames: frames, result: result);
    } else {
      // ignore: avoid_print
      print('🟡 [ScoringPersistenceController] No local data — trying RTDB for $matchId');
      final remoteJson = await _rtdb.fetchOnce(matchId);
      if (remoteJson != null) {
        // ignore: avoid_print
        print('🟢 [ScoringPersistenceController] Loaded from RTDB for $matchId');
        ScoreLocalStorageService.applyJsonToControllers(remoteJson, score: score, frames: frames, result: result);
      }
    }

    _startListeningForRemoteUpdates(matchId);
  }

  /// Subscribes to live RTDB updates — applies incoming data straight onto
  /// the controllers. Harmless even on the scorer's own device (it's just
  /// receiving back what it already sent), and essential for a second/
  /// viewing device to actually see live progress.
  void _startListeningForRemoteUpdates(String matchId) {
    _remoteSubscription?.cancel();
    _remoteSubscription = _rtdb.listenForUpdates(
      matchId,
      onUpdate: (data) {
        ScoreLocalStorageService.applyJsonToControllers(data, score: score, frames: frames, result: result);
      },
    );
  }

  /// Saves current state to local storage AND pushes it through the
  /// active sync transport (RTDB by default). Call this after any user
  /// action that changes scoring/frame/match state.
  void persist() {
    if (_matchId == null) return;

    // ignore: avoid_print
    print('🟣 [ScoringPersistenceController] persist() called for $_matchId');

    final json = ScoreLocalStorageService.buildJson(score: score, frames: frames, result: result);

    _storage.save(_matchId!, score: score, frames: frames, result: result);
    syncMode.sendUpdate(_matchId!, json);

    // If this device is actively previewing/streaming (CameraStreamController
    // registered), also push the fresh scores straight to the burned-in
    // scoreboard overlay — so whatever's shown in the video always
    // matches the actual current score, live.
    if (Get.isRegistered<CameraStreamController>() && _side1Name != null) {
      final camera = Get.find<CameraStreamController>();
      if (camera.isPreviewActive.value) {
        final matchData = buildScoreboardMatchData(
          score: score,
          frames: frames,
          side1Name: _side1Name!,
          side2Name: _side2Name!,
          eventName: _eventName ?? '',
          roundName: _roundName ?? '',
          totalFrames: _totalFrames,
        );
        camera.updateScoreboard(matchData);
      }
    }
  }

  @override
  void onClose() {
    _remoteSubscription?.cancel();
    super.onClose();
  }
}