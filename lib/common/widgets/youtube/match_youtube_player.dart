import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class MatchVideoPlayer extends StatefulWidget {
  final String youtubeLink;
  const MatchVideoPlayer({super.key, required this.youtubeLink});

  @override
  State<MatchVideoPlayer> createState() => _MatchVideoPlayerState();
}

class _MatchVideoPlayerState extends State<MatchVideoPlayer> {
  late YoutubePlayerController _controller;
  bool showControls = true;
  bool isMuted = true;
  Timer? hideTimer;
  final List<double> speeds = [0.5, 1, 1.25, 1.5, 2];
  double currentSpeed = 1;

  @override
  void initState() {
    super.initState();
    final videoId = YoutubePlayer.convertUrlToId(widget.youtubeLink)!;
    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: true,
        hideControls: true,
        hideThumbnail: true,
        disableDragSeek: false,
      ),
    );
    startHideTimer();
  }

  void startHideTimer() {
    hideTimer?.cancel();
    hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => showControls = false);
    });
  }

  void toggleControls() {
    setState(() => showControls = !showControls);
    if (showControls) startHideTimer();
  }

  void toggleMute() {
    setState(() {
      isMuted = !isMuted;
      isMuted ? _controller.mute() : _controller.unMute();
    });
  }

  void seekForward() =>
      _controller.seekTo(_controller.value.position + const Duration(seconds: 10));

  void seekBackward() =>
      _controller.seekTo(_controller.value.position - const Duration(seconds: 10));

  void changeSpeed(double speed) {
    setState(() => currentSpeed = speed);
    _controller.setPlaybackRate(speed);
  }

  void enterFullscreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void exitFullscreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return d.inHours > 0 ? '${d.inHours}:$m:$s' : '$m:$s';
  }

  Widget buildControls(bool isLandscape) {
    if (!showControls) return const SizedBox();

    return Positioned.fill(
      child: GestureDetector(
        onTap: toggleControls,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xCC000000),
                Colors.transparent,
                Colors.transparent,
                Color(0xCC000000),
              ],
              stops: [0, 0.25, 0.75, 1],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              // ── TOP BAR ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                child: Row(
                  children: [
                    if (isLandscape)
                      _iconBtn(Icons.arrow_back_ios_new, exitFullscreen, size: 18)
                    else
                      const SizedBox(width: 48),
                    const Spacer(),
                    // Speed selector
                    PopupMenuButton<double>(
                      color: const Color(0xFF1C1C1C),
                      onSelected: changeSpeed,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      itemBuilder: (_) => speeds.map((s) => PopupMenuItem(
                        value: s,
                        child: Row(
                          children: [
                            Icon(Icons.speed,
                                size: 16,
                                color: s == currentSpeed ? Colors.red : Colors.white54),
                            const SizedBox(width: 8),
                            Text('${s}x',
                                style: TextStyle(
                                    color: s == currentSpeed ? Colors.red : Colors.white,
                                    fontWeight: s == currentSpeed
                                        ? FontWeight.bold
                                        : FontWeight.normal)),
                          ],
                        ),
                      )).toList(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.speed, color: Colors.white, size: 14),
                            const SizedBox(width: 4),
                            Text('${currentSpeed}x',
                                style: const TextStyle(color: Colors.white, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Mute
                    _circleBtn(
                      isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                      toggleMute,
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),

              // ── CENTER CONTROLS ──
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _centerBtn(Icons.replay_10_rounded, seekBackward, 44),
                  const SizedBox(width: 28),
                  // Big play/pause
                  GestureDetector(
                    onTap: () {
                      _controller.value.isPlaying
                          ? _controller.pause()
                          : _controller.play();
                      setState(() {});
                    },
                    child: Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: Colors.white12,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white38, width: 1.5),
                      ),
                      child: Icon(
                        _controller.value.isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                  const SizedBox(width: 28),
                  _centerBtn(Icons.forward_10_rounded, seekForward, 44),
                ],
              ),

              // ── BOTTOM BAR ──
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                child: Column(
                  children: [
                    // Progress + time
                    Row(
                      children: [
                        ValueListenableBuilder(
                          valueListenable: _controller,
                          builder: (_, value, __) => Text(
                            _fmt(value.position),
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 11),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: ProgressBar(
                              controller: _controller,
                              colors: const ProgressBarColors(
                                playedColor: Colors.red,
                                handleColor: Colors.redAccent,
                                bufferedColor: Colors.white24,
                                backgroundColor: Colors.white12,
                              ),
                            ),
                          ),
                        ),
                        ValueListenableBuilder(
                          valueListenable: _controller,
                          builder: (_, value, __) => Text(
                            _fmt(value.metaData.duration),
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _iconBtn(
                          isLandscape ? Icons.fullscreen_exit : Icons.fullscreen,
                          isLandscape ? exitFullscreen : enterFullscreen,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap, {double size = 22}) {
    return IconButton(
      icon: Icon(icon, color: Colors.white, size: size),
      onPressed: onTap,
      padding: const EdgeInsets.all(8),
    );
  }

  Widget _circleBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: Colors.white12,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }

  Widget _centerBtn(IconData icon, VoidCallback onTap, double size) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white10,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24),
        ),
        child: Icon(icon, color: Colors.white, size: size),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return GestureDetector(
      onTap: toggleControls,
      child: AspectRatio(
        aspectRatio: isLandscape
            ? MediaQuery.of(context).size.aspectRatio
            : 16 / 9,
        child: Stack(
          fit: StackFit.expand,
          children: [
            YoutubePlayer(
              controller: _controller,
              showVideoProgressIndicator: false,
            ),
            buildControls(isLandscape),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    hideTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }
}