// lib/features/streaming/presentation/widgets/streaming_error_dialog.dart

import 'package:flutter/material.dart';

void showStreamingErrorDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: const Color(0xFF1F2937),
      title: const Row(
        children: [
          Icon(Icons.error_outline, color: Color(0xFFEF4444)),
          SizedBox(width: 8),
          Text('Error', style: TextStyle(color: Colors.white)),
        ],
      ),
      content: Text(
        message,
        style: const TextStyle(color: Colors.white70),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3B82F6),
          ),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}