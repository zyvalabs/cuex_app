import 'package:flutter/material.dart';
import '../../../controllers/frame_tracking_controller.dart';
import '../../../controllers/score_controller.dart';


/// Frame-by-frame history table — left column always shows whoever broke
/// (fixed for the whole match), right shows the other player. Center
/// column is the frame number. Score pill + break number + trophy icon
/// shows the winner (green) or in-progress state (amber).
class FrameHistoryTable extends StatelessWidget {
  final String breakerName;
  final String otherName;
  final List<FrameResult> frames;
  final bool isCurrentFrameActive;
  final int currentFrameNumber;
  final int currentSide1Score;
  final int currentSide2Score;
  final int currentSide1Break;
  final int currentSide2Break;
  final bool breakerIsSide1; // whether "breaker" column maps to side1 or side2 data

  const FrameHistoryTable({
    super.key,
    required this.breakerName,
    required this.otherName,
    required this.frames,
    required this.isCurrentFrameActive,
    required this.currentFrameNumber,
    required this.currentSide1Score,
    required this.currentSide2Score,
    required this.currentSide1Break,
    required this.currentSide2Break,
    required this.breakerIsSide1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildHeaderRow(),
          for (final frame in frames) ...[
            const Divider(height: 1),
            _buildDataRow(
              breakerScore: breakerIsSide1 ? frame.side1Score : frame.side2Score,
              otherScore: breakerIsSide1 ? frame.side2Score : frame.side1Score,
              breakerBreak: breakerIsSide1 ? frame.side1Break : frame.side2Break,
              otherBreak: breakerIsSide1 ? frame.side2Break : frame.side1Break,
              frameNumber: frame.frameNumber,
              isComplete: true,
              breakerWon: frame.winningSide == null
                  ? null
                  : (breakerIsSide1 ? frame.winningSide == 1 : frame.winningSide == 2),
            ),
          ],
          if (isCurrentFrameActive) ...[
            const Divider(height: 1),
            _buildDataRow(
              breakerScore: breakerIsSide1 ? currentSide1Score : currentSide2Score,
              otherScore: breakerIsSide1 ? currentSide2Score : currentSide1Score,
              breakerBreak: breakerIsSide1 ? currentSide1Break : currentSide2Break,
              otherBreak: breakerIsSide1 ? currentSide2Break : currentSide1Break,
              frameNumber: currentFrameNumber,
              isComplete: false,
              breakerWon: null,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(breakerName, style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 40, child: Text('Brk', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: Colors.grey))),
          const SizedBox(width: 50, child: Text('Frame', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey))),
          const SizedBox(width: 40, child: Text('Brk', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: Colors.grey))),
          Expanded(
            flex: 3,
            child: Text(otherName, textAlign: TextAlign.right, style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildDataRow({
    required int breakerScore,
    required int otherScore,
    required int breakerBreak,
    required int otherBreak,
    required int frameNumber,
    required bool isComplete,
    required bool? breakerWon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                _buildScorePill(breakerScore, isComplete && breakerWon == true, isComplete),
                if (isComplete && breakerWon == true) ...[
                  const SizedBox(width: 6),
                  Icon(Icons.emoji_events, size: 14, color: Colors.green.shade700),
                ],
              ],
            ),
          ),
          SizedBox(width: 40, child: Text('$breakerBreak', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Colors.black54))),
          SizedBox(width: 50, child: Text('$frameNumber', textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700))),
          SizedBox(width: 40, child: Text('$otherBreak', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Colors.black54))),
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isComplete && breakerWon == false) ...[
                  Icon(Icons.emoji_events, size: 14, color: Colors.green.shade700),
                  const SizedBox(width: 6),
                ],
                _buildScorePill(otherScore, isComplete && breakerWon == false, isComplete),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScorePill(int score, bool isWinner, bool isComplete) {
    final color = !isComplete ? Colors.amber : (isWinner ? Colors.green : Colors.grey);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
      child: Text(
        '$score',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: !isComplete ? Colors.amber.shade800 : (isWinner ? Colors.green.shade700 : Colors.black54),
        ),
      ),
    );
  }
}