import 'package:flutter/material.dart';

class ComparisonRow extends StatelessWidget {
  final String metric;
  final String cuexcam;
  final String traditional;
  final String improvement;

  const ComparisonRow({
    super.key,
    required this.metric,
    required this.cuexcam,
    required this.traditional,
    required this.improvement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF101010),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.03)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(metric, style: const TextStyle(color: Colors.white)),
          ),
          Expanded(
            flex: 2,
            child: Text(
              cuexcam,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.greenAccent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              traditional,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              improvement,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.greenAccent,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
