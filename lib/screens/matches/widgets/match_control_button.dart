import 'package:flutter/material.dart';

import '../../../common/widgets/buttons/app_button.dart';


/// Fixed bottom button toggling between "Start Match" and "End Match".
/// Dummy UI for now — isMatchStarted is just passed in, no controller wired yet.
class MatchControlButton extends StatelessWidget {
  final bool isMatchStarted;
  final VoidCallback onPressed;

  const MatchControlButton({
    super.key,
    required this.isMatchStarted,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppButton(
      text: isMatchStarted ? 'End Match' : 'Start Match',
      backgroundColor: isMatchStarted ? Colors.red : Colors.black,
      onPressed: onPressed,
    );
  }
}