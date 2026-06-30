
// ─────────────────────────────────────────────
// Search Bar
// ─────────────────────────────────────────────

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class EventSearchBar extends StatelessWidget {
  const EventSearchBar({
    required this.controller,
    required this.query,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final String query;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.07)),
        ),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.white,
          ),
          decoration: InputDecoration(
            hintText: 'Search events...',
            hintStyle: const TextStyle(
              fontSize: 13,
              color: Colors.white30,
            ),
            prefixIcon: const Icon(
              Iconsax.search_normal,
              size: 17,
              color: Colors.white30,
            ),
            suffixIcon: query.isNotEmpty
                ? GestureDetector(
              onTap: onClear,
              child: const Icon(
                Icons.close_rounded,
                size: 17,
                color: Colors.white38,
              ),
            )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }
}