import 'package:flutter/material.dart';

class MatchStatusBadge extends StatelessWidget {
  const MatchStatusBadge({super.key, required this.status});
  final String status;

  Color get _color {
    switch (status.toLowerCase()) {
      case 'live': return Colors.redAccent;
      case 'upcoming': return Colors.green;
      case 'completed': return Colors.grey;
      default: return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final isTablet = sw > 600;
    final fontSize = isTablet ? 12.0 : 10.0;
    final padH = isTablet ? 14.0 : 10.0;
    final padV = isTablet ? 6.0 : 4.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (status.toLowerCase() == 'live')
          Container(
            width: 6, height: 6,
            margin: const EdgeInsets.only(right: 5),
            decoration: BoxDecoration(color: _color, shape: BoxShape.circle),
          ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
          child: Text(
            status.toUpperCase(),
            style: TextStyle(
              color: _color,
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }
}