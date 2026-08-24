import 'package:flutter/material.dart';
import '../../../common/widgets/buttons/app_button.dart';

/// Bottom sheet shown when "End Match" is tapped — lets the scorer confirm
/// the match winner. Pre-selects whoever's currently leading in frames won,
/// but scorer can override by tapping the other side.
class MatchWinnerSheet extends StatefulWidget {
  final String side1Label;
  final String side2Label;
  final int side1FramesWon;
  final int side2FramesWon;
  final ValueChanged<int> onConfirm; // returns 1 or 2

  const MatchWinnerSheet({
    super.key,
    required this.side1Label,
    required this.side2Label,
    required this.side1FramesWon,
    required this.side2FramesWon,
    required this.onConfirm,
  });

  static Future<void> show(
      BuildContext context, {
        required String side1Label,
        required String side2Label,
        required int side1FramesWon,
        required int side2FramesWon,
        required ValueChanged<int> onConfirm,
      }) {
    return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => MatchWinnerSheet(
        side1Label: side1Label,
        side2Label: side2Label,
        side1FramesWon: side1FramesWon,
        side2FramesWon: side2FramesWon,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  State<MatchWinnerSheet> createState() => _MatchWinnerSheetState();
}

class _MatchWinnerSheetState extends State<MatchWinnerSheet> {
  late int selected;

  @override
  void initState() {
    super.initState();
    // Pre-select whoever's currently leading — defaults to side 1 on a tie.
    selected = widget.side2FramesWon > widget.side1FramesWon ? 2 : 1;
  }

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
            'Confirm Match Winner',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          _buildOption(widget.side1Label, widget.side1FramesWon, 1),
          const SizedBox(height: 10),
          _buildOption(widget.side2Label, widget.side2FramesWon, 2),
          const SizedBox(height: 20),
          AppButton(
            text: 'End Match',
            onPressed: () {
              widget.onConfirm(selected);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOption(String label, int framesWon, int side) {
    final isSelected = selected == side;

    return GestureDetector(
      onTap: () => setState(() => selected = side),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            Text(
              '$framesWon frames',
              style: TextStyle(
                color: isSelected ? Colors.white70 : Colors.grey,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}