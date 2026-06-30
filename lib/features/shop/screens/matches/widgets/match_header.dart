import 'package:flutter/material.dart';

class MatchHeader extends StatelessWidget {
  const MatchHeader({
    super.key,
    required this.eventName,
    required this.roundName,
    required this.status,
    this.statusColor = Colors.red,
  });

  final String eventName;
  final String roundName;
  final String status;
  final Color statusColor;

  String get _capitalizedRound => roundName
      .split(' ')
      .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            eventName.toUpperCase(),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),

        ],
      ),
    );
  }
}