import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../../../common/widgets/shimmers/shimmer.dart';
import '../../../../../data/repositories/events/event_repository.dart';
import '../../../../../data/repositories/match%20stats/match_stats_repository.dart';
import '../../../../../data/repositories/matches/matches_repository.dart';
import '../../../../../data/repositories/user/user_repository.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../personalization/controllers/user_controller.dart';

// ─────────────────────────────────────────────
// Break Entry Model
// ─────────────────────────────────────────────

class _BreakEntry {
  final int breakScore;
  final int frameNumber;
  final String opponentName;
  final String eventName;
  final DateTime date;

  const _BreakEntry({
    required this.breakScore,
    required this.frameNumber,
    required this.opponentName,
    required this.eventName,
    required this.date,
  });
}

// ─────────────────────────────────────────────
// MyBreaksWidget
// ─────────────────────────────────────────────

class MyBreaksWidget extends StatefulWidget {
  final String? userId; // ✅ add
  const MyBreaksWidget({super.key, this.userId}); // ✅ add

  @override
  State<MyBreaksWidget> createState() => _MyBreaksWidgetState();
}

class _MyBreaksWidgetState extends State<MyBreaksWidget>
    with AutomaticKeepAliveClientMixin {

  // ✅ cached future
  late final Future<List<_BreakEntry>> _future;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _future = _fetchBreaks();
  }

  Future<List<_BreakEntry>> _fetchBreaks() async {
    final userId = widget.userId ?? UserController.instance.user.value.id;
    final matchRepo = Get.put(MatchRepository());
    final statsRepo = Get.put(MatchStatsRepository());
    final userRepo = Get.put(UserRepository());
    final eventRepo = Get.put(EventRepository());

    final matches = await matchRepo.fetchMatchesByPlayer(userId);
    final breaks = <_BreakEntry>[];

    await Future.wait(matches.map((match) async {
      try {
        final frames = await statsRepo.fetchFramesByMatch(match.id);
        final isPlayer1 = match.player1Id == userId;
        final opponentId = isPlayer1 ? match.player2Id : match.player1Id;

        final opponent = opponentId != null
            ? await userRepo.fetchUserById(opponentId)
            : null;

        final event = match.eventId.isNotEmpty
            ? await eventRepo.fetchSingleItem(match.eventId)
            : null;

        final opponentName = opponent != null
            ? '${opponent.firstName} ${opponent.lastName}'.trim()
            : 'Unknown';
        final eventName = event?.name ?? 'Practice';

        for (final frame in frames) {
          final score = isPlayer1
              ? frame.player1HighestBreak
              : frame.player2HighestBreak;

          if (score > 0) {
            breaks.add(_BreakEntry(
              breakScore: score,
              frameNumber: frame.frameNumber,
              opponentName: opponentName,
              eventName: eventName,
              date: match.scheduledTime,
            ));
          }
        }
      } catch (_) {}
    }));

    breaks.sort((a, b) => b.breakScore.compareTo(a.breakScore));
    return breaks;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return FutureBuilder<List<_BreakEntry>>(
      future: _future,
      builder: (context, snapshot) {
        // ── Loading ──────────────────────
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _BreaksShimmer();
        }

        // ── Error ─────────────────────────
        if (snapshot.hasError) {
          return const _ErrorState();
        }

        final breaks = snapshot.data ?? [];

        // ── Empty ─────────────────────────
        if (breaks.isEmpty) {
          return const _EmptyState();
        }

        // ── List ──────────────────────────
        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 100),
          child: Column(
            children: breaks.asMap().entries.map((entry) {
              return _BreakCard(
                entry: entry.value,
                rank: entry.key + 1,
                isTop: entry.key == 0,
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// Break Card
// ─────────────────────────────────────────────

class _BreakCard extends StatelessWidget {
  const _BreakCard({
    required this.entry,
    required this.rank,
    required this.isTop,
  });

  final _BreakEntry entry;
  final int rank;
  final bool isTop;

  Color get _rankColor {
    switch (rank) {
      case 1: return const Color(0xFF2ECC71);
      case 2: return const Color(0xFFD4A843);
      case 3: return const Color(0xFFCD7F32);
      default: return Colors.white24;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isTop
              ? TColors.june.withOpacity(0.3)
              : Colors.white.withOpacity(0.06),
        ),
      ),
      child: Row(
        children: [
          // ── Rank badge ──────────────────
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _rankColor.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: _rankColor.withOpacity(0.3)),
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: TextStyle(
                  color: _rankColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // ── Info ────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Event name
                Text(
                  entry.eventName,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white.withOpacity(0.35),
                    letterSpacing: 0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),

                // Opponent
                Text(
                  'vs ${entry.opponentName}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // Frame + date
                Row(
                  children: [
                    Icon(
                      Iconsax.layer,
                      size: 10,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      'Frame ${entry.frameNumber}',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Icon(
                      Iconsax.calendar,
                      size: 10,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      DateFormat('dd MMM yyyy').format(entry.date),
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // ── Break score ─────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${entry.breakScore}',
                style: GoogleFonts.bebasNeue(
                  fontSize: 32,
                  color: isTop ? TColors.june : Colors.white70,
                  letterSpacing: 1,
                  height: 1,
                ),
              ),
              Text(
                'BREAK',
                style: TextStyle(
                  fontSize: 8,
                  color: isTop
                      ? TColors.june.withOpacity(0.6)
                      : Colors.white.withOpacity(0.2),
                  letterSpacing: 2,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Shimmer
// ─────────────────────────────────────────────

class _BreaksShimmer extends StatelessWidget {
  const _BreaksShimmer();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 100),
      child: Column(
        children: List.generate(5, (_) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF141414),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              TShimmerEffect(width: 36, height: 36, radius: 18),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TShimmerEffect(width: 80, height: 10, radius: 4),
                    const SizedBox(height: 5),
                    TShimmerEffect(width: 130, height: 13, radius: 4),
                    const SizedBox(height: 6),
                    TShimmerEffect(width: 100, height: 10, radius: 4),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              TShimmerEffect(width: 40, height: 40, radius: 4),
            ],
          ),
        )),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Empty State
// ─────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: TColors.june.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Iconsax.cup, size: 28, color: TColors.june.withOpacity(0.5)),
          ),
          const SizedBox(height: 12),
          const Text(
            'No Breaks Yet',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Your highest breaks will appear here',
            style: TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Error State
// ─────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  const _ErrorState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Iconsax.warning_2, size: 28, color: Colors.red),
          ),
          const SizedBox(height: 12),
          const Text(
            'Something went wrong',
            style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          const Text(
            'Pull down to try again',
            style: TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ],
      ),
    );
  }
}