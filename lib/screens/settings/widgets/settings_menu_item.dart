import 'package:flutter/material.dart';

/// Reusable settings list item — icon, label, chevron, tap action.
/// Use for My Matches, My Events, Stream Settings, FAQ, Logout, Delete Account, etc.
class SettingsMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color iconColor;
  final Color labelColor;
  final bool showChevron;

  const SettingsMenuItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor = Colors.black,
    this.labelColor = Colors.black,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: labelColor),
              ),
            ),
            if (showChevron) const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }
}