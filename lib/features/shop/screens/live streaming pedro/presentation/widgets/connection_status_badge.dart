// lib/features/streaming/presentation/widgets/connection_status_badge.dart

import 'package:flutter/material.dart';

import '../state/stream_state.dart';

/// Connection status badge widget
class ConnectionStatusBadge extends StatelessWidget {
  final ConnectionStatus status;
  final int reconnectAttempts;
  final int maxAttempts;

  const ConnectionStatusBadge({
    super.key,
    required this.status,
    this.reconnectAttempts = 0,
    this.maxAttempts = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getStatusColor(),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Status indicator
          _buildStatusIndicator(),

          const SizedBox(width: 8),

          // Status text
          Text(
            _getStatusText(),
            style: TextStyle(
              color: _getStatusColor(),
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  /// Build animated status indicator
  Widget _buildStatusIndicator() {
    // Show pulsing animation for connecting/reconnecting/live
    if (status == ConnectionStatus.connecting ||
        status == ConnectionStatus.reconnecting ||
        status == ConnectionStatus.live) {
      return _PulsingDot(color: _getStatusColor());
    }

    // Static dot for other states
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: _getStatusColor(),
        shape: BoxShape.circle,
      ),
    );
  }

  /// Get status text with reconnection attempts if applicable
  String _getStatusText() {
    if (status == ConnectionStatus.reconnecting) {
      return 'Reconnecting $reconnectAttempts/$maxAttempts';
    }
    return status.displayText;
  }

  /// Get status color
  Color _getStatusColor() {
    switch (status) {
      case ConnectionStatus.disconnected:
        return Colors.grey;
      case ConnectionStatus.connecting:
        return Colors.amber;
      case ConnectionStatus.connected:
        return Colors.green;
      case ConnectionStatus.reconnecting:
        return Colors.amber;
      case ConnectionStatus.live:
        return Colors.red;
      case ConnectionStatus.error:
        return Colors.red;
    }
  }
}

/// Pulsing dot animation for active states
class _PulsingDot extends StatefulWidget {
  final Color color;

  const _PulsingDot({required this.color});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: widget.color.withOpacity(_animation.value),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(_animation.value * 0.5),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
        );
      },
    );
  }
}