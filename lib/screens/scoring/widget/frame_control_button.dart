import 'package:flutter/material.dart';

/// Row of small action buttons — Undo, Reset, and Start/End Frame (label
/// toggles based on isFrameActive).
class FrameControlButtons extends StatelessWidget {
  final bool isFrameActive;
  final VoidCallback onUndo;
  final VoidCallback onReset;
  final VoidCallback onStartOrEndFrame;

  const FrameControlButtons({
    super.key,
    required this.isFrameActive,
    required this.onUndo,
    required this.onReset,
    required this.onStartOrEndFrame,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _ActionButton(label: 'Undo', onTap: onUndo)),
        const SizedBox(width: 10),
        Expanded(child: _ActionButton(label: 'Reset', onTap: onReset)),
        const SizedBox(width: 10),
        Expanded(
          child: _ActionButton(
            label: isFrameActive ? 'End Frame' : 'Start Frame',
            onTap: onStartOrEndFrame,
            isHighlighted: isFrameActive,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isHighlighted;

  const _ActionButton({required this.label, required this.onTap, this.isHighlighted = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isHighlighted ? Colors.red : const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isHighlighted ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}