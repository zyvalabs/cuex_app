// lib/screens/player_live_stream/player_live_streaming_screen.dart

import 'package:cuex_app/features/shop/screens/matches/create_match_screen.dart';
import 'package:cuex_app/features/shop/screens/streaming/widgets/comparison_row.dart';
import 'package:cuex_app/features/shop/screens/streaming/widgets/final_cta.dart';
import 'package:cuex_app/features/shop/screens/streaming/widgets/requirement_card.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../../common/widgets/buttons/custom_button.dart';
import '../../../../common/widgets/tile/feature_tile.dart';
import '../../../../common/widgets/tile/section_title.dart';
import '../../../../common/widgets/video/video_preview.dart';
import '../../../../stream_screen.dart';

class PlayerLiveStreamingScreen extends StatefulWidget {
  const PlayerLiveStreamingScreen({super.key});

  @override
  State<PlayerLiveStreamingScreen> createState() =>
      _PlayerLiveStreamingScreenState();
}

class _PlayerLiveStreamingScreenState
    extends State<PlayerLiveStreamingScreen>
    with TickerProviderStateMixin {
  late VideoPlayerController _videoController;
  late AnimationController _heroController;
  late AnimationController _buttonController;

  late Animation<double> _scaleAnim;
  late Animation<Offset> _buttonSlide;

  @override
  void initState() {
    super.initState();

    // 🎥 Video controller
    _videoController =
    VideoPlayerController.asset("assets/videos/livestreaming.mp4")
      ..initialize().then((_) {
        _videoController.setLooping(true);
        _videoController.setVolume(0);
        _videoController.play();

        if (mounted) {
          setState(() {});
        }
      });

    // Hero animation
    _heroController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _scaleAnim = Tween<double>(
      begin: 0.94,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _heroController,
        curve: Curves.easeOut,
      ),
    );

    // Floating button animation
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _buttonSlide = Tween<Offset>(
      begin: const Offset(0, 1.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _buttonController,
        curve: Curves.easeOutCubic,
      ),
    );

    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted) {
        _heroController.forward();
        _buttonController.forward();
      }
    });
  }

  @override
  void dispose() {
    _videoController.dispose();
    _heroController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const themeRed = Color(0xFFEF4444);

    final maxWidth = MediaQuery.of(context).size.width > 1100
        ? 1100.0
        : MediaQuery.of(context).size.width - 36;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),

      // ---------------------------
      // FLOATING BUTTON
      // ---------------------------
      bottomNavigationBar: SlideTransition(
        position: _buttonSlide,
        child: Padding(
          padding: EdgeInsets.only(
            left: 18,
            right: 18,
            bottom: MediaQuery.of(context).padding.bottom + 18,
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: themeRed.withOpacity(0.45),
                  blurRadius: 18,
                  spreadRadius: 2,

                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: CustomButton(
              text: "Go Live",
              icon: Icons.wifi_tethering,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CreateMatchScreen(isPractice: true,),
                  ),
                );
              },
              backgroundColor: themeRed,
              paddingVertical: 18,
              borderRadius: 14,
            ),
          ),
        ),
      ),

      // ---------------------------
      // APP BAR
      // ---------------------------
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 26,
          ),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Image.asset(
          "assets/images/streaming/cue_cam.png",
          height: 180,
          fit: BoxFit.contain,
        ),
      ),

      // ---------------------------
      // BODY
      // ---------------------------
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // HERO
                ScaleTransition(
                  scale: _scaleAnim,
                  child: Column(
                    children: [
                      const Text(
                        "Stream Cue Sports Worldwide",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        "Using only your smartphone — instant, portable, affordable.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.78),
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 12),
                      //
                      // Container(
                      //   padding: const EdgeInsets.symmetric(
                      //     horizontal: 18,
                      //     vertical: 10,
                      //   ),
                      //   decoration: BoxDecoration(
                      //     color: themeRed,
                      //     borderRadius: BorderRadius.circular(14),
                      //     boxShadow: [
                      //       BoxShadow(
                      //         color: themeRed.withOpacity(0.16),
                      //         blurRadius: 16,
                      //         offset: const Offset(0, 8),
                      //       ),
                      //     ],
                      //   ),
                      //   child: const Text(
                      //     "Launching Soon",
                      //     style: TextStyle(
                      //       color: Colors.white,
                      //       fontWeight: FontWeight.w800,
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),

                const SizedBox(height: 26),

                VideoPreview(controller: _videoController),

                const SizedBox(height: 28),

                // FEATURES
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    children: [
                      const SectionTitle(
                        title: "Core Features",
                        subtitle: "Everything you get with CuexCam",
                      ),

                      const SizedBox(height: 14),

                      FeatureTile(
                        icon: Icons.phone_android,
                        title: "Phone-Only Streaming",
                        subtitle:
                        "Go live instantly from any Android or iPhone.",
                        color: themeRed,
                      ),

                      const SizedBox(height: 12),

                      FeatureTile(
                        icon: Icons.wifi,
                        title: "Low Latency",
                        subtitle:
                        "Optimized delivery for near real-time viewing.",
                        color: Colors.blueAccent,
                      ),

                      const SizedBox(height: 12),

                      FeatureTile(
                        icon: Icons.scoreboard,
                        title: "Scoring App Included",
                        subtitle:
                        "Connects to your stream and overlays scores in real-time.",
                        color: Colors.greenAccent,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // REQUIREMENTS
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    children: [
                      const SectionTitle(
                        title: "What You Need",
                        subtitle: "Minimal setup — we handle the rest",
                      ),

                      const SizedBox(height: 16),

                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.65,
                        children: const [
                          RequirementCard(
                            icon: Icon(
                              Icons.wifi,
                              color: Colors.white,
                            ),
                            title: "WiFi / 4G / 5G",
                            subtitle: "10–20 Mbps upload recommended.",
                            requiredBadge: true,
                          ),

                          RequirementCard(
                            icon: Icon(
                              Icons.battery_charging_full,
                              color: Colors.white,
                            ),
                            title: "Power",
                            subtitle:
                            "Keep your device charged for long sessions.",
                          ),

                          RequirementCard(
                            icon: Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                            ),
                            title: "Tripod",
                            subtitle: "A stable mount or tripod.",
                          ),

                          RequirementCard(
                            icon: Icon(
                              Icons.person,
                              color: Colors.white,
                            ),
                            title: "Anyone Can Stream",
                            subtitle: "Players, coaches, venues.",
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // COMPARISON
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: const [
                      SectionTitle(
                        title: "CuexCam vs Traditional",
                        subtitle: "Quick comparison (high-level)",
                      ),

                      SizedBox(height: 12),

                      ComparisonRow(
                        metric: "Cost",
                        cuexcam: "Minimal",
                        traditional: "Expensive setup",
                        improvement: "≈90% cheaper",
                      ),

                      ComparisonRow(
                        metric: "Setup Time",
                        cuexcam: "30 seconds",
                        traditional: "3–6 hours",
                        improvement: "≈90% faster",
                      ),

                      ComparisonRow(
                        metric: "Staff Required",
                        cuexcam: "0 people",
                        traditional: "2–4 staff",
                        improvement: "≈90% less staff",
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 34),
                //
                // const FinalCtaSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}