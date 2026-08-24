import 'package:flutter/material.dart';

/// Shows upload speed (Mbps) — determines stream quality/stability.
/// Dummy data for now — no real network measurement wired yet.
class NetworkSpeedWidget extends StatelessWidget {
  final double uploadMbps;

  const NetworkSpeedWidget({super.key, this.uploadMbps = 8.4});

  Color get _statusColor {
    if (uploadMbps >= 5) return Colors.green;
    if (uploadMbps >= 2) return Colors.amber;
    return Colors.red;
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
          Icon(Icons.wifi, color: _statusColor, size: 14),
          const SizedBox(width: 4),
          Text(
            '${uploadMbps.toStringAsFixed(1)} Mbps',
            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}