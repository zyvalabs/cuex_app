import 'package:flutter/material.dart';

class FinalCtaSection extends StatelessWidget {
  const FinalCtaSection({super.key});

  @override
  Widget build(BuildContext context) {
    const themeRed = Color(0xFFEF4444);

    return Column(
      children: [
        // Image.asset("assets/images/streaming/cue_cam.png", height: 140),
        const SizedBox(height: 12),

        const Text(
          "CuexCam — Launching Soon",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          "We provide the mobile scoring app and cloud tools to make streaming simple and professional.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white.withOpacity(0.75)),
        ),

        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: themeRed,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            "Coming Soon",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: 26),
      ],
    );
  }
}
