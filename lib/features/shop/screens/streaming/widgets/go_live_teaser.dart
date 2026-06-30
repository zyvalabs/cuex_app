import 'package:flutter/material.dart';

import 'hero_section.dart';


class PlayerGoLiveTeaser extends StatelessWidget {
  const PlayerGoLiveTeaser({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print('PlayerLiveStreamingScreen tapped');
      },

      child: HeroSectionClean(
        title: "Live Stream Your Game",
        subtitle: "Broadcast cue sports to the world — straight from your phone.",
        videoAsset: "assets/videos/livestreaming.mp4",
        logoAsset: "assets/images/streaming/cue_cam.png",
      ),
    );
  }
}
