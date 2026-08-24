import 'package:cuex_app/screens/live%20streaming/widgets/battery_indicator.dart';
import 'package:cuex_app/screens/live%20streaming/widgets/network_speed.dart';
import 'package:cuex_app/screens/live%20streaming/widgets/timer_widget.dart';
import 'package:cuex_app/screens/live%20streaming/widgets/zoom_control.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../common/widgets/buttons/app_button.dart';


/// Go Live camera screen — always opens in landscape. Shows camera preview
/// placeholder with overlaid status widgets (network, battery, timer) and
/// zoom control, back button top-left, Start Preview button at bottom.
/// Dummy UI/data for now — no camera/RootEncoder wiring yet.
class GoLiveCameraScreen extends StatefulWidget {
  const GoLiveCameraScreen({super.key});

  @override
  State<GoLiveCameraScreen> createState() => _GoLiveCameraScreenState();
}

class _GoLiveCameraScreenState extends State<GoLiveCameraScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Camera preview placeholder — full screen
            Positioned.fill(
              child: Container(
                color: Colors.black,
                alignment: Alignment.center,
                child: const Text(
                  'Camera preview will appear here',
                  style: TextStyle(color: Colors.white38, fontSize: 14),
                ),
              ),
            ),

            // Back button — top-left
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),

            // Status widgets — top-right, stacked
            const Positioned(
              top: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  RecordingTimerWidget(),
                  SizedBox(height: 8),
                  NetworkSpeedWidget(),
                  SizedBox(height: 8),
                  BatteryIndicatorWidget(),
                ],
              ),
            ),

            // Zoom control — right side, vertically centered
            Positioned(
              right: 16,
              top: 0,
              bottom: 0,
              child: Center(
                child: ZoomControlWidget(
                  onZoomIn: () {},
                  onZoomOut: () {},
                ),
              ),
            ),

            // Start Preview button — bottom
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: AppButton(
                text: 'Start Preview',
                onPressed: () {
                  // TODO: check camera/mic permissions, then start
                  // RootEncoder preview once granted.
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}