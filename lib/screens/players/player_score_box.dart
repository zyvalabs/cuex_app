import 'package:flutter/material.dart';

/// Responsive, modern score box — supports Solo/Singles (1 name) and
/// Doubles (2 names stacked), with an optional team name shown at top.
/// Score is a single shared number for the whole side (team or individual).
/// isActive shows a green highlight border when this side is currently
/// active/selected — tapping the box also sets it active (dual-trigger
/// with the switch button, both update the same ScoreController state).
class PlayerScoreBox extends StatelessWidget {
  final List<String> playerNames;
  final String? teamName;
  final int score;
  final bool isActive;
  final VoidCallback? onTap;

  const PlayerScoreBox({
    super.key,
    required this.playerNames,
    this.teamName,
    required this.score,
    this.isActive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 150;

        return GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: isCompact ? 16 : 24, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(16),
              border: isActive ? Border.all(color: Colors.green, width: 3) : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (teamName != null && teamName!.isNotEmpty) ...[
                  Text(
                    teamName!,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: isCompact ? 11 : 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                for (final name in playerNames)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 1),
                    child: Text(
                      name,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isCompact ? 13 : 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                SizedBox(height: isCompact ? 6 : 8),
                Text(
                  '$score',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isCompact ? 32 : 40,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}