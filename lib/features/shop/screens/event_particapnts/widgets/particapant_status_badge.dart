import 'package:flutter/material.dart';

class ParticipantStatusBadge extends StatelessWidget {
  const ParticipantStatusBadge({super.key, required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case 'confirmed':
        color = Colors.green;
        label = 'Confirmed';
        break;
      case 'withdrawn':
        color = Colors.red;
        label = 'Withdrawn';
        break;
      case 'disqualified':
        color = Colors.orange;
        label = 'Disqualified';
        break;
      default:
        color = Colors.blue;
        label = 'Registered';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}