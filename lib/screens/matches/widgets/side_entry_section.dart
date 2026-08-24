import 'package:flutter/material.dart';

/// Reusable "side" card — optional team name + 1 or 2 player name fields.
/// Used twice (Side A / Side B) for Singles (1 player each) or
/// Doubles (2 players each). Solo uses just one instance with no "vs".
class SideEntrySection extends StatelessWidget {
  final String sideLabel; // e.g. "Side A", "Side B"
  final TextEditingController teamNameController;
  final List<TextEditingController> playerControllers; // 1 or 2 controllers
  final ValueChanged<String>? onAnyFieldChanged;

  const SideEntrySection({
    super.key,
    required this.sideLabel,
    required this.teamNameController,
    required this.playerControllers,
    this.onAnyFieldChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(sideLabel, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: teamNameController,
            onChanged: onAnyFieldChanged,
            decoration: InputDecoration(
              hintText: 'Team name (optional)',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 8),
          for (int i = 0; i < playerControllers.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            TextField(
              controller: playerControllers[i],
              onChanged: onAnyFieldChanged,
              decoration: InputDecoration(
                hintText: 'Player ${i + 1} name',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}