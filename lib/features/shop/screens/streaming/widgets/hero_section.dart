import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class HeroSectionClean extends StatefulWidget {
  final String title;
  final String subtitle;
  final String videoAsset;
  final String logoAsset;

  const HeroSectionClean({
    super.key,
    required this.title,
    required this.subtitle,
    required this.videoAsset,
    required this.logoAsset,
  });

  @override
  State<HeroSectionClean> createState() => _HeroSectionCleanState();
}

class _HeroSectionCleanState extends State<HeroSectionClean>
    with TickerProviderStateMixin {
  late VideoPlayerController _controller;
  late AnimationController _blinkCtrl;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.asset(widget.videoAsset)
      ..initialize().then((_) {
        _controller.setLooping(true);
        _controller.setVolume(0);
        _controller.play();
        setState(() {});
      });

    _blinkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _blinkCtrl.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const red = Color(0xFFE50914);

    return SizedBox(
      height: 360,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // -------------------------------
          // VIDEO BACKGROUND (Always Bright)
          // -------------------------------
          if (_controller.value.isInitialized)
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller.value.size.width,
                height: _controller.value.size.height,
                child: VideoPlayer(_controller),
              ),
            )
          else
            Container(color: Colors.black),

          // -------------------------------
          // Light Gradient for Legibility
          // -------------------------------
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.55),
                  Colors.black.withOpacity(0.18),
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),

          // -------------------------------
          // BIG LOGO TOP-CENTER
          // -------------------------------
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                widget.logoAsset,
                height: 180, // BIGGER LOGO
                fit: BoxFit.contain,
              ),
            ),
          ),

          // -------------------------------
          // SMALLER LIVE INDICATOR (TOP RIGHT)
          // -------------------------------
          Positioned(
            top: 18,
            right: 18,
            child: FadeTransition(
              opacity: Tween(begin: 0.4, end: 1.0).animate(_blinkCtrl),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: red,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      "LIVE",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13, // smaller text
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // -------------------------------
          // CENTER CONTENT (Bigger Title)
          // -------------------------------
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 95), // Space for the top logo

                  // TITLE (BIGGER + CLEAN)
                  Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32, // Bigger
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // SUBTITLE (LARGER & CLEAR)
                  Text(
                    widget.subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 16, // Bigger subtitle
                    ),
                  ),

                  const SizedBox(height: 14),

                  // BULLET POINT ROW
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _bullet("Phone-Only"),
                      const SizedBox(width: 18),
                      _bullet("HD Streaming"),
                      const SizedBox(width: 18),
                      _bullet("Zero Setup"),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // LAUNCHING SOON (Moved Down)
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      "LAUNCHING SOON",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14, // Slightly bigger
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // BULLET POINT
  Widget _bullet(String text) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14, // improved font size
          ),
        ),
      ],
    );
  }
}
