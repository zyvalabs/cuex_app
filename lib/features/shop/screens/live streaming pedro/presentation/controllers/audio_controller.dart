import 'package:get/get.dart';

import '../../../../../../data/services/streaming/streaming_service.dart';

class AudioController extends GetxController {
  // Observable state
  final isMuted = false.obs;
  final isToggling = false.obs;
  final error = Rx<String?>(null);

  Future<void> toggleMute() async {
    try {
      isToggling.value = true;
      error.value = null;

      final currentlyMuted = isMuted.value;

      final success = currentlyMuted
          ? await StreamingService.unmuteAudio()
          : await StreamingService.muteAudio();

      if (success) {
        isMuted.value = !currentlyMuted;
      }

      _logEvent('audio_toggled', {'muted': !currentlyMuted});
    } catch (e) {
      error.value = e.toString();
    } finally {
      isToggling.value = false;
    }
  }

  Future<void> mute() async {
    if (isMuted.value) return;

    try {
      isToggling.value = true;
      error.value = null;

      final success = await StreamingService.muteAudio();

      if (success) {
        isMuted.value = true;
      }

      _logEvent('audio_muted');
    } catch (e) {
      error.value = e.toString();
    } finally {
      isToggling.value = false;
    }
  }

  Future<void> unmute() async {
    if (!isMuted.value) return;

    try {
      isToggling.value = true;
      error.value = null;

      final success = await StreamingService.unmuteAudio();

      if (success) {
        isMuted.value = false;
      }

      _logEvent('audio_unmuted');
    } catch (e) {
      error.value = e.toString();
    } finally {
      isToggling.value = false;
    }
  }

  void _logEvent(String event, [Map<String, dynamic>? data]) {
    print('Analytics: $event ${data ?? ""}');
  }
}
//
// // Usage
// final audioController = Get.put(AudioController());
//
// // In UI
// Obx(() => IconButton(
// icon: Icon(audioController.isMuted.value ? Icons.mic_off : Icons.mic),
// onPressed: audioController.isToggling.value ? null : () => audioController.toggleMute(),
// ))