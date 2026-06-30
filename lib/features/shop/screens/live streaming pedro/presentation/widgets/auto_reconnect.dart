import 'package:flutter/material.dart';

class AutoReconnectWidget extends StatelessWidget {
  final bool isVisible;
  final bool isEnabled;
  final VoidCallback onToggle;

  const AutoReconnectWidget({
    super.key,
    required this.isVisible,
    required this.isEnabled,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Auto-Reconnect',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: isEnabled,
            onChanged: (_) => onToggle(),
            activeThumbColor: const Color(0xFF10B981),
          ),
        ],
      ),
    );
  }
}