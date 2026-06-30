import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class MatchTime extends StatelessWidget {
  const MatchTime({super.key, required this.scheduledTime});
  final DateTime scheduledTime;

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final isTablet = sw > 600;
    final isDesktop = sw > 900;
    final labelSize = isDesktop ? 22.0 : isTablet ? 20.0 : 16.0;
    final timeSize = isDesktop ? 34.0 : isTablet ? 30.0 : 24.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _getDateLabel(scheduledTime),
          style: GoogleFonts.bebasNeue(
            color: Colors.white,
            fontSize: labelSize,
            letterSpacing: 1.2,
          ),
        ),
        Text(
          DateFormat('h a').format(scheduledTime),
          style: GoogleFonts.bebasNeue(
            color: Colors.white54,
            fontSize: timeSize,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  String _getDateLabel(DateTime scheduledTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final matchDay = DateTime(scheduledTime.year, scheduledTime.month, scheduledTime.day);
    if (matchDay == today) return 'TODAY';
    if (matchDay == tomorrow) return 'TOMORROW';
    final day = DateFormat('d').format(scheduledTime);
    final suffix = _getDaySuffix(int.parse(day));
    final month = DateFormat('MMM').format(scheduledTime);
    return '$day$suffix $month';
  }

  String _getDaySuffix(int day) {
    if (day >= 11 && day <= 13) return 'th';
    switch (day % 10) {
      case 1: return 'st';
      case 2: return 'nd';
      case 3: return 'rd';
      default: return 'th';
    }
  }
}