import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/match_creation_controller.dart';


/// Shows either the login prompt (disconnected) or the connected channel
/// card — all UI inline here, wired directly to MatchCreationController.
class YoutubeConnectionSection extends StatelessWidget {
  const YoutubeConnectionSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MatchCreationController>();

    return Obx(() {
      if (controller.isYoutubeConnected.value) {
        // ---- Connected state: channel card ----
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F2F2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.grey.shade300,
                backgroundImage: controller.youtubeChannelImageUrl.value != null
                    ? NetworkImage(controller.youtubeChannelImageUrl.value!)
                    : null,
                child: controller.youtubeChannelImageUrl.value == null
                    ? const Icon(Icons.person, color: Colors.grey)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Connected Channel', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 2),
                    Text(
                      controller.youtubeChannelName.value ?? 'Connected',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => controller.disconnectYoutube(),
                child: const Text('Disconnect', style: TextStyle(color: Colors.redAccent)),
              ),
            ],
          ),
        );
      }

      // ---- Disconnected state: login prompt ----
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Setup YouTube Stream', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          const Text('Connect your YouTube channel to go live', style: TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () async {
                try {
                  await controller.connectYoutube();
                  controller.autoFillYoutubeMetadata();
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to connect: $e')),
                    );
                  }
                }
              },
              icon: const Icon(Icons.play_circle_fill, color: Colors.white, size: 20),
              label: const Text(
                'Login with YouTube',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      );
    });
  }
}