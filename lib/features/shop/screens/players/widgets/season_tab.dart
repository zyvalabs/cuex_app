import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../data/repositories/match stats/match_stats_repository.dart';
import '../../../../../data/repositories/matches/matches_repository.dart';

import '../../../models/match_model.dart';

class _PlayerSeasonStats {
  final int totalMatches;
  final int wins;
  final int totalFrames;
  final int framesWon;
  final int highestBreak;
  final int centuries;
  final int totalPoints;

  _PlayerSeasonStats({
    required this.totalMatches,
    required this.wins,
    required this.totalFrames,
    required this.framesWon,
    required this.highestBreak,
    required this.centuries,
    required this.totalPoints,
  });

  double get winRate => totalMatches == 0 ? 0 : wins / totalMatches;
  double get frameWinRate => totalFrames == 0 ? 0 : framesWon / totalFrames;
  int get losses => totalMatches - wins;
}

class SeasonStatsWidget extends StatelessWidget {
  const SeasonStatsWidget({
    super.key,
    required this.match,
    required this.player1Name,
    required this.player2Name,
  });

  final MatchModel match;
  final String player1Name;
  final String player2Name;

  Future<Map<String, _PlayerSeasonStats>> _fetchStats() async {
    final matchRepo = Get.put(MatchRepository());
    final statsRepo = Get.put(MatchStatsRepository());

    Future<_PlayerSeasonStats> getStats(String playerId) async {
      final matches = await matchRepo.fetchMatchesByPlayer(playerId);
      int wins = 0, totalFrames = 0, framesWon = 0;
      int highestBreak = 0, centuries = 0, totalPoints = 0;

      await Future.wait(matches.map((m) async {
        if (m.winnerId == playerId) wins++;
        final frames = await statsRepo.fetchFramesByMatch(m.id);
        final isP1 = m.player1Id == playerId;
        for (final f in frames) {
          totalFrames++;
          final pts = isP1 ? f.player1Points : f.player2Points;
          final brk = isP1 ? f.player1HighestBreak : f.player2HighestBreak;
          if (f.winnerId == playerId) framesWon++;
          totalPoints += pts;
          if (brk > highestBreak) highestBreak = brk;
          if (brk >= 100) centuries++;
        }
      }));

      return _PlayerSeasonStats(
        totalMatches: matches.length,
        wins: wins,
        totalFrames: totalFrames,
        framesWon: framesWon,
        highestBreak: highestBreak,
        centuries: centuries,
        totalPoints: totalPoints,
      );
    }

    final results = await Future.wait([
      getStats(match.player1Id!),
      getStats(match.player2Id!),
    ]);

    return {
      'player1': results[0],
      'player2': results[1],
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, _PlayerSeasonStats>>(
      future: _fetchStats(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.red));
        }

        if (!snapshot.hasData) {
          return const Center(
            child: Text('No stats available',
                style: TextStyle(color: Colors.white38)),
          );
        }

        final p1 = snapshot.data!['player1']!;
        final p2 = snapshot.data!['player2']!;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    player1Name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 80,
                  child: Text(
                    'STAT',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white24,
                      fontSize: 10,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    player2Name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Win Rate Rings
            Row(
              children: [
                Expanded(
                  child: _MiniRing(
                    value: p1.winRate,
                    label: '${(p1.winRate * 100).toStringAsFixed(0)}%',
                    color: Colors.red,
                  ),
                ),
                const SizedBox(
                  width: 80,
                  child: Text(
                    'Win Rate',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                ),
                Expanded(
                  child: _MiniRing(
                    value: p2.winRate,
                    label: '${(p2.winRate * 100).toStringAsFixed(0)}%',
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Frame Win Rate Rings
            Row(
              children: [
                Expanded(
                  child: _MiniRing(
                    value: p1.frameWinRate,
                    label: '${(p1.frameWinRate * 100).toStringAsFixed(0)}%',
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(
                  width: 80,
                  child: Text(
                    'Frame Rate',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                ),
                Expanded(
                  child: _MiniRing(
                    value: p2.frameWinRate,
                    label: '${(p2.frameWinRate * 100).toStringAsFixed(0)}%',
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Stat rows
            _StatCompareRow(
              label: 'Matches',
              p1Value: '${p1.totalMatches}',
              p2Value: '${p2.totalMatches}',
              p1Better: p1.totalMatches >= p2.totalMatches,
            ),
            _StatCompareRow(
              label: 'Wins',
              p1Value: '${p1.wins}',
              p2Value: '${p2.wins}',
              p1Better: p1.wins >= p2.wins,
            ),
            _StatCompareRow(
              label: 'Losses',
              p1Value: '${p1.losses}',
              p2Value: '${p2.losses}',
              p1Better: p1.losses <= p2.losses,
            ),
            _StatCompareRow(
              label: 'Frames Won',
              p1Value: '${p1.framesWon}',
              p2Value: '${p2.framesWon}',
              p1Better: p1.framesWon >= p2.framesWon,
            ),
            _StatCompareRow(
              label: 'Highest Break',
              p1Value: '${p1.highestBreak}',
              p2Value: '${p2.highestBreak}',
              p1Better: p1.highestBreak >= p2.highestBreak,
            ),
            _StatCompareRow(
              label: 'Centuries',
              p1Value: '${p1.centuries}',
              p2Value: '${p2.centuries}',
              p1Better: p1.centuries >= p2.centuries,
            ),
            _StatCompareRow(
              label: 'Total Points',
              p1Value: '${p1.totalPoints}',
              p2Value: '${p2.totalPoints}',
              p1Better: p1.totalPoints >= p2.totalPoints,
            ),
          ],
        );
      },
    );
  }
}

// --- Mini Ring ---
class _MiniRing extends StatelessWidget {
  const _MiniRing({
    required this.value,
    required this.label,
    required this.color,
  });

  final double value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      child: CustomPaint(
        painter: _RingPainter(progress: value, color: color),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;

  _RingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 6;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi,
      false,
      Paint()
        ..color = Colors.white10
        ..strokeWidth = 6
        ..style = PaintingStyle.stroke,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..color = color
        ..strokeWidth = 6
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

// --- Stat Compare Row ---
class _StatCompareRow extends StatelessWidget {
  const _StatCompareRow({
    required this.label,
    required this.p1Value,
    required this.p2Value,
    required this.p1Better,
  });

  final String label;
  final String p1Value;
  final String p2Value;
  final bool p1Better;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              p1Value,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: p1Better ? Colors.red : Colors.white38,
                fontSize: 15,
                fontWeight:
                p1Better ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          SizedBox(
            width: 80,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white38, fontSize: 11),
            ),
          ),
          Expanded(
            child: Text(
              p2Value,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: !p1Better ? Colors.blue : Colors.white38,
                fontSize: 15,
                fontWeight:
                !p1Better ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}