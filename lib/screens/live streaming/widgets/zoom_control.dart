import 'package:flutter/material.dart';

/// Zoom in/out control — vertical +/- pair, overlaid on camera preview.
/// Dummy UI for now — no actual camera zoom wired yet.
class ZoomControlWidget extends StatelessWidget {
  final VoidCallback? onZoomIn;
  final VoidCallback? onZoomOut;

  const ZoomControlWidget({super.key, this.onZoomIn, this.onZoomOut});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white, size: 20),
            onPressed: onZoomIn,
          ),
          Container(width: 20, height: 1, color: Colors.white24),
          IconButton(
            icon: const Icon(Icons.remove, color: Colors.white, size: 20),
            onPressed: onZoomOut,
          ),
        ],
      ),
    );
  }
}