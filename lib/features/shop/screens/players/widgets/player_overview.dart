import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../common/widgets/shimmers/shimmer.dart';
import '../../../../../data/repositories/events/event_repository.dart';
import '../../../../../data/repositories/events/events_participants.dart';
import '../../../../../data/repositories/match%20stats/match_stats_repository.dart';
import '../../../../../data/repositories/matches/matches_repository.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../personalization/controllers/user_controller.dart';
import 'ring_card.dart';
import 'stat_tile.dart';

// ─────────────────────────────────────────────
// Player Stats Model
// ─────────────────────────────────────────────

class PlayerStats {
  final int totalMatches;
  final int wins;
  final int losses;
  final int totalFrames;
  final int framesWon;
  final int highestBreak;
  final int centuries;
  final int totalPoints;
  final int eventsPlayed;
  final int eventsWon;

  const PlayerStats({
    required this.totalMatches,
    required this.wins,
    required this.losses,
    required this.totalFrames,
    required this.framesWon,
    required this.highestBreak,
    required this.centuries,
    required this.totalPoints,
    required this.eventsPlayed,
    required this.eventsWon,
  });

  double get winRate => totalMatches == 0 ? 0 : wins / totalMatches;
  double get frameWinRate => totalFrames == 0 ? 0 : framesWon / totalFrames;
}

// ─────────────────────────────────────────────
// PlayerOverviewWidget
// ─────────────────────────────────────────────

class PlayerOverviewWidget extends StatefulWidget {
  final String? userId; // ✅ optional — fallback to logged-in user

  const PlayerOverviewWidget({super.key, this.userId});

  @override
  State<PlayerOverviewWidget> createState() => _PlayerOverviewWidgetState();
}

class _PlayerOverviewWidgetState extends State<PlayerOverviewWidget>
    with AutomaticKeepAliveClientMixin {

  // ✅ cached future
  late final Future<PlayerStats> _future;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // ✅ use passed userId or fallback to logged-in user
    final userId = widget.userId ?? UserController.instance.user.value.id;
    _future = _fetchStats(userId);
  }

  Future<PlayerStats> _fetchStats(String userId) async {
    try {
      final matchRepo = Get.put(MatchRepository());
      final statsRepo = Get.put(MatchStatsRepository());
      final eventRepo = Get.put(EventRepository());
      final participantRepo = Get.put(EventParticipantRepository());

      final matches = await matchRepo.fetchMatchesByPlayer(userId);

      int wins = 0, totalFrames = 0, framesWon = 0;
      int highestBreak = 0, centuries = 0, totalPoints = 0;

      await Future.wait(matches.map((match) async {
        if (match.winnerId == userId) wins++;

        try {
          final frames = await statsRepo.fetchFramesByMatch(match.id);
          final isPlayer1 = match.player1Id == userId;

          for (final frame in frames) {
            totalFrames++;
            final pts = isPlayer1
                ? frame.player1Points
                : frame.player2Points;
            final brk = isPlayer1
                ? frame.player1HighestBreak
                : frame.player2HighestBreak;
            final won = frame.winnerId == userId;

            if (won) framesWon++;
            totalPoints += pts;
            if (brk > highestBreak) highestBreak = brk;
            if (brk >= 100) centuries++;
          }
        } catch (_) {}
      }));

      final participations =
      await participantRepo.fetchParticipantsByUser(userId);
      final eventsPlayed = participations.length;

      final allEvents = await eventRepo.fetchAllItems();
      final eventsWon =
          allEvents.where((e) => e.winnerId == userId).length;

      return PlayerStats(
        totalMatches: matches.length,
        wins: wins,
        losses: matches.length - wins,
        totalFrames: totalFrames,
        framesWon: framesWon,
        highestBreak: highestBreak,
        centuries: centuries,
        totalPoints: totalPoints,
        eventsPlayed: eventsPlayed,
        eventsWon: eventsWon,
      );
    } catch (e) {
      debugPrint('🔴 _fetchStats error: $e');
      return PlayerStats(
        totalMatches: 0, wins: 0, losses: 0,
        totalFrames: 0, framesWon: 0, highestBreak: 0,
        centuries: 0, totalPoints: 0, eventsPlayed: 0, eventsWon: 0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return FutureBuilder<PlayerStats>(
      future: _future,
      builder: (context, snapshot) {
        // ── Shimmer ──────────────────────
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _OverviewShimmer();
        }

        // ── Error / no data ───────────────
        if (!snapshot.hasData) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Iconsax.chart,
                    size: 28,
                    color: Colors.white24,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'No stats available',
                  style: TextStyle(color: Colors.white38, fontSize: 13),
                ),
              ],
            ),
          );
        }

        final s = snapshot.data!;

        // ── Stats ─────────────────────────
        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
          child: Column(
            children: [
              // ── Win rate rings ────────────
              Row(
                children: [
                  Expanded(
                    child: RingStatCard(
                      label: 'Match Win Rate',
                      value: s.winRate,
                      displayText:
                      '${(s.winRate * 100).toStringAsFixed(0)}%',
                      color: TColors.june,
                      subtitle: '${s.wins}W  ${s.losses}L',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RingStatCard(
                      label: 'Frame Win Rate',
                      value: s.frameWinRate,
                      displayText:
                      '${(s.frameWinRate * 100).toStringAsFixed(0)}%',
                      color: Colors.orange,
                      subtitle: '${s.framesWon}/${s.totalFrames} frames',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ── Stats grid ────────────────
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.4,
                children: [
                  StatTile(
                    icon: Iconsax.video_play,
                    label: 'Matches',
                    value: '${s.totalMatches}',
                    color: Colors.blue,
                  ),
                  StatTile(
                    icon: Iconsax.cup,
                    label: 'Highest Break',
                    value: '${s.highestBreak}',
                    color: const Color(0xFFD4A843),
                  ),
                  StatTile(
                    icon: Iconsax.star,
                    label: 'Centuries',
                    value: '${s.centuries}',
                    color: Colors.purple,
                  ),
                  StatTile(
                    icon: Iconsax.chart,
                    label: 'Total Points',
                    value: '${s.totalPoints}',
                    color: TColors.june,
                  ),
                  StatTile(
                    icon: Iconsax.calendar,
                    label: 'Events Played',
                    value: '${s.eventsPlayed}',
                    color: Colors.orange,
                  ),
                  StatTile(
                    icon: Iconsax.medal,
                    label: 'Events Won',
                    value: '${s.eventsWon}',
                    color: Colors.red,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// Overview Shimmer
// ─────────────────────────────────────────────

class _OverviewShimmer extends StatelessWidget {
  const _OverviewShimmer();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      child: Column(
        children: [
          // Rings shimmer
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 140,
                  decoration: BoxDecoration(
                    color: const Color(0xFF141414),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Center(
                    child: TShimmerEffect(width: 80, height: 80, radius: 40),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 140,
                  decoration: BoxDecoration(
                    color: const Color(0xFF141414),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Center(
                    child: TShimmerEffect(width: 80, height: 80, radius: 40),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Grid shimmer
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: List.generate(
              6,
                  (_) => Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF141414),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.05)),
                ),
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TShimmerEffect(width: 24, height: 24, radius: 6),
                    TShimmerEffect(width: 50, height: 20, radius: 4),
                    TShimmerEffect(width: 80, height: 10, radius: 4),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}