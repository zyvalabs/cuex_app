import 'package:flutter/material.dart';
import '../../../common/widgets/buttons/app_button.dart';

/// Bottom sheet shown when tapping "Start Match" — lets the scorer pick
/// who's breaking. Selected player becomes the initial active player.
/// Pure UI — caller handles what happens with the selection.
class BreakingPlayerSheet extends StatefulWidget {
  final String side1Label; // player or team name for side 1
  final String side2Label; // player or team name for side 2
  final ValueChanged<int> onConfirm; // returns 1 or 2

  const BreakingPlayerSheet({
    super.key,
    required this.side1Label,
    required this.side2Label,
    required this.onConfirm,
  });

  /// Convenience method to show this as a modal bottom sheet.
  static Future<void> show(
      BuildContext context, {
        required String side1Label,
        required String side2Label,
        required ValueChanged<int> onConfirm,
      }) {
    return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => BreakingPlayerSheet(
        side1Label: side1Label,
        side2Label: side2Label,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  State<BreakingPlayerSheet> createState() => _BreakingPlayerSheetState();
}

class _BreakingPlayerSheetState extends State<BreakingPlayerSheet> {
  int? selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Who is breaking?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          _buildOption(widget.side1Label, 1),
          const SizedBox(height: 10),
          _buildOption(widget.side2Label, 2),
          const SizedBox(height: 20),
          AppButton(
            text: 'Start Match',
            onPressed: selected == null
                ? null
                : () {
              widget.onConfirm(selected!);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOption(String label, int side) {
    final isSelected = selected == side;

    return GestureDetector(
      onTap: () => setState(() => selected = side),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}