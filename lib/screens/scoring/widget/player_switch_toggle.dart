import 'package:flutter/material.dart';

import '../../../common/widgets/buttons/app_button.dart';


/// Single button, same style as Start/End Match — tapping switches the
/// active player. Shows the ACTUAL name of whoever you'd switch TO
/// (not generic "Player 1/2"), so it reads naturally, e.g. "Switch to Ravi".
class PlayerSwitchToggle extends StatelessWidget {
  final String otherPlayerName; // name of the player NOT currently active
  final VoidCallback onSwitch;

  const PlayerSwitchToggle({
    super.key,
    required this.otherPlayerName,
    required this.onSwitch,
  });

  @override
  Widget build(BuildContext context) {
    return AppButton(
      text: 'Switch to $otherPlayerName',
      backgroundColor: Colors.white,
      textColor: Colors.black,
      onPressed: onSwitch,
    );
  }
}