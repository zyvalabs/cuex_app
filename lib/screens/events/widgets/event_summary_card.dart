import 'package:flutter/material.dart';

import '../../../core/model/event_model.dart';


/// Shows the created event's details — name, sport, format.
class EventSummaryCard extends StatelessWidget {
  final EventModel event;

  const EventSummaryCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(event.eventName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(
            event.format.isNotEmpty ? '${event.sport} · ${event.format}' : event.sport,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
          if (event.raceToPoints != null) ...[
            const SizedBox(height: 4),
            Text('Race to ${event.raceToPoints}', style: const TextStyle(fontSize: 13, color: Colors.grey)),
          ],
        ],
      ),
    );
  }
}