import 'package:cuex_app/controllers/rtmp_setup_controller.dart';
import 'package:cuex_app/controllers/youtube_setup_controller.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/model/match_model.dart';
import '../repositories/match_repository.dart';
import 'match_setup_controller.dart';


/// Orchestrates the final match creation — reads from MatchSetupController,
/// YoutubeSetupController, and RtmpSetupController (each registered via
/// Get.find where needed), assembles the final MatchModel, and saves it.
/// Does NOT hold step-specific state itself — that lives in the 3 sub-controllers.
class MatchCreationController extends GetxController {
  final MatchRepository _matchRepository = MatchRepository();

  String get _userId => FirebaseAuth.instance.currentUser!.uid;

  // ---------------- Step 3: Streaming platform choice ----------------
  final RxnString streamPlatform = RxnString(); // 'YouTube' | 'RTMP'

  void selectStreamPlatform(String platform) => streamPlatform.value = platform;

  // ---------------- Final save ----------------
  final RxBool isSaving = false.obs;
  final RxnString saveError = RxnString();

  Future<String?> createMatch() async {
    isSaving.value = true;
    saveError.value = null;

    final matchSetup = Get.find<MatchSetupController>();

    try {
      String? broadcastId;
      String? resolvedRtmpUrl;
      String? resolvedStreamKey;

      if (streamPlatform.value == 'YouTube') {
        final youtube = Get.find<YoutubeSetupController>();
        final result = await youtube.createLiveBroadcast();
        broadcastId = result['broadcast_id'];
        resolvedRtmpUrl = result['rtmp_url'];
        resolvedStreamKey = result['stream_key'];
      } else if (streamPlatform.value == 'RTMP') {
        final rtmp = Get.find<RtmpSetupController>();
        resolvedRtmpUrl = rtmp.rtmpUrl.value;
        resolvedStreamKey = rtmp.streamKey.value;
      }

      final match = MatchModel(
        sport: matchSetup.selectedSport.value.name,
        matchType: matchSetup.selectedMatchType.value ?? '',
        format: matchSetup.selectedFormatValue.value ?? '',
        bestOfFrames: matchSetup.bestOfFrames.value,
        mode: matchSetup.mode.value,
        playerNames: matchSetup.playerControllers
            .take(matchSetup.playerFieldCount)
            .map((c) => c.text.trim())
            .toList(),
        streamPlatform: streamPlatform.value ?? '',
        youtubeTitle: streamPlatform.value == 'YouTube' ? Get.find<YoutubeSetupController>().youtubeTitle.value : null,
        youtubeDescription:
        streamPlatform.value == 'YouTube' ? Get.find<YoutubeSetupController>().youtubeDescription.value : null,
        youtubeThumbnailUrl:
        streamPlatform.value == 'YouTube' ? Get.find<YoutubeSetupController>().youtubeThumbnailUrl.value : null,
        youtubeVisibility:
        streamPlatform.value == 'YouTube' ? Get.find<YoutubeSetupController>().youtubeVisibility.value : null,
        youtubeScheduledStartTime: streamPlatform.value == 'YouTube' &&
            Get.find<YoutubeSetupController>().isScheduled.value
            ? Get.find<YoutubeSetupController>().youtubeScheduledStartTime.value
            : null,
        youtubeBroadcastId: broadcastId,
        rtmpUrl: resolvedRtmpUrl,
        streamKey: resolvedStreamKey,
        createdBy: _userId,
        createdAt: DateTime.now(),
        eventId: matchSetup.eventId.value,
        roundName:
        matchSetup.roundNameController.text.trim().isNotEmpty ? matchSetup.roundNameController.text.trim() : null,
        teamNameA:
        matchSetup.teamNameAController.text.trim().isNotEmpty ? matchSetup.teamNameAController.text.trim() : null,
        teamNameB:
        matchSetup.teamNameBController.text.trim().isNotEmpty ? matchSetup.teamNameBController.text.trim() : null,
      );

      final matchId = await _matchRepository.createMatch(match);

      isSaving.value = false;
      return matchId;
    } catch (e) {
      saveError.value = e.toString();
      isSaving.value = false;
      return null;
    }
  }
}