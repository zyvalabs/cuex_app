import 'package:flutter/material.dart';

/// Shows elapsed recording/live time (HH:MM:SS or MM:SS). Dummy static
/// value for now — no real timer ticking yet.
class RecordingTimerWidget extends StatelessWidget {
  final Duration elapsed;
  final bool isLive;

  const RecordingTimerWidget({
    super.key,
    this.elapsed = const Duration(minutes: 4, seconds: 23),
    this.isLive = true,
  });

  String get _formatted {
    final h = elapsed.inHours;
    final m = elapsed.inMinutes.remainder(60);
    final s = elapsed.inSeconds.remainder(60);
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLive) ...[
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            _formatted,
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}