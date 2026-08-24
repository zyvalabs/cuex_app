import 'package:flutter/material.dart';

/// Shows battery level — long streams drain battery fast, worth
/// surfacing on screen. Dummy data for now.
class BatteryIndicatorWidget extends StatelessWidget {
  final int batteryPercent;

  const BatteryIndicatorWidget({super.key, this.batteryPercent = 72});

  Color get _statusColor {
    if (batteryPercent >= 40) return Colors.green;
    if (batteryPercent >= 15) return Colors.amber;
    return Colors.red;
  }

  IconData get _icon {
    if (batteryPercent >= 90) return Icons.battery_full;
    if (batteryPercent >= 50) return Icons.battery_5_bar;
    if (batteryPercent >= 20) return Icons.battery_2_bar;
    return Icons.battery_alert;
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
          Icon(_icon, color: _statusColor, size: 14),
          const SizedBox(width: 4),
          Text(
            '$batteryPercent%',
            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}