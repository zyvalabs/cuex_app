import 'package:flutter/material.dart';
import '../../../../../../utils/constants/enums.dart';

class EventStatusBadge extends StatelessWidget {
  const EventStatusBadge({super.key, required this.status});
  final EventStatus status;

  Color get _color {
    switch (status) {
      case EventStatus.live: return Colors.red;
      case EventStatus.upcoming: return Colors.green;
      case EventStatus.completed: return Colors.grey;
    }
  }

  String get _label {
    switch (status) {
      case EventStatus.live: return 'LIVE';
      case EventStatus.upcoming: return 'UPCOMING';
      case EventStatus.completed: return 'COMPLETED';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: _color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            _label,
            style: TextStyle(
              color: _color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}