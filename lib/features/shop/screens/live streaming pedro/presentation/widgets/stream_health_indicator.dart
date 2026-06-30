// lib/features/streaming/presentation/widgets/stream_health_indicator.dart

import 'package:flutter/material.dart';

import '../state/stream_state.dart';

/// Stream health indicator widget
class StreamHealthIndicator extends StatelessWidget {
  final StreamHealth health;

  const StreamHealthIndicator({
    super.key,
    required this.health,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getQualityColor().withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Quality indicator dot
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _getQualityColor(),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _getQualityColor().withOpacity(0.5),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Bitrate display
          Text(
            _formatBitrate(health.currentBitrate),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(width: 8),

          // Divider
          Container(
            width: 1,
            height: 16,
            color: Colors.white.withOpacity(0.3),
          ),

          const SizedBox(width: 8),

          // Quality text
          Text(
            _getQualityText(),
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Get quality color based on health
  Color _getQualityColor() {
    if (health.quality.contains('🟢')) return const Color(0xFF10B981);
    if (health.quality.contains('🟡')) return const Color(0xFFF59E0B);
    if (health.quality.contains('🔴')) return const Color(0xFFEF4444);
    return const Color(0xFF6B7280);
  }

  /// Get quality text without emoji
  String _getQualityText() {
    if (health.quality.contains('GOOD')) return 'Excellent';
    if (health.quality.contains('FAIR')) return 'Fair';
    if (health.quality.contains('LOW')) return 'Poor';
    return 'Unknown';
  }

  /// Format bitrate for display
  String _formatBitrate(int bitrateKbps) {
    if (bitrateKbps >= 1000) {
      return '${(bitrateKbps / 1000).toStringAsFixed(1)} Mbps';
    }
    return '$bitrateKbps kbps';
  }
}