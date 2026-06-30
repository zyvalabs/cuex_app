// lib/common/widgets/streaming_icon_button.dart
import 'package:flutter/material.dart';

class StreamingIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color? iconColor;
  final bool isEnabled;
  final double size;

  const StreamingIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.iconColor,
    this.isEnabled = true,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isEnabled
          ? Colors.black.withOpacity(0.6)
          : Colors.grey.withOpacity(0.6),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Icon(
            icon,
            color: isEnabled ? (iconColor ?? Colors.white) : Colors.white38,
            size: size,
          ),
        ),
      ),
    );
  }
}
