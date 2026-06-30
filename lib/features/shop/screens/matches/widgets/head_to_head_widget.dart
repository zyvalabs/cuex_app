import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../data/repositories/matches/matches_repository.dart';
import '../../../models/match_model.dart';
import '../../matches/match_detail.dart';
import '../../../../../common/widgets/matches/card/match_card.dart';

class HeadToHeadWidget extends StatelessWidget {
  const HeadToHeadWidget({
    super.key,
    required this.match,
    required this.player1Name,
    required this.player2Name,
  });

  final MatchModel match;
  final String player1Name;
  final String player2Name;

  Future<List<MatchModel>> _fetchH2H() async {
    final repo = Get.put(MatchRepository());
    final p1 = match.player1Id!;
    final p2 = match.player2Id!;

    // Fetch matches for both players
    final p1Matches = await repo.fetchMatchesByPlayer(p1);
    final p2Matches = await repo.fetchMatchesByPlayer(p2);

    print('🔍 Looking for p1: $p1 p2: $p2');
    print('🎯 p1 matches: ${p1Matches.length}');
    print('🎯 p2 matches: ${p2Matches.length}');

    // Combine and deduplicate
    final allIds = <String>{};
    final allMatches = <MatchModel>[];

    for (final m in [...p1Matches, ...p2Matches]) {
      if (allIds.contains(m.id)) continue;
      allIds.add(m.id);

      // Must involve both players
      final involves = (m.player1Id == p1 && m.player2Id == p2) ||
          (m.player1Id == p2 && m.player2Id == p1);

      print('📋 match ${m.id} p1:${m.player1Id} p2:${m.player2Id} involves:$involves');

      if (involves) {
        allMatches.add(m);
      }
    }

    allMatches.sort((a, b) => b.scheduledTime.compareTo(a.scheduledTime));
    print('✅ H2H final: ${allMatches.length}');
    return allMatches;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MatchModel>>(
      key: ValueKey('h2h_${match.id}'),
      future: _fetchH2H(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.red));
        }

        final matches = snapshot.data ?? [];

        // H2H record
        int p1Wins = 0, p2Wins = 0;
        for (final m in matches) {
          if (m.winnerId == match.player1Id) p1Wins++;
          if (m.winnerId == match.player2Id) p2Wins++;
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // H2H Summary
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF141414),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                children: [
                  const Text(
                    'HEAD TO HEAD',
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 11,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Text(
                            '$p1Wins',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            player1Name,
                            style: const TextStyle(
                                color: Colors.white54, fontSize: 12),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            '${matches.length}',
                            style: const TextStyle(
                                color: Colors.white24, fontSize: 14),
                          ),
                          const Text(
                            'matches',
                            style: TextStyle(
                                color: Colors.white24, fontSize: 10),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            '$p2Wins',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            player2Name,
                            style: const TextStyle(
                                color: Colors.white54, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Win bar
                  if (matches.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Row(
                        children: [
                          Expanded(
                            flex: p1Wins == 0 && p2Wins == 0 ? 1 : (p1Wins == 0 ? 1 : p1Wins),
                            child: Container(height: 6, color: Colors.red),
                          ),
                          Expanded(
                            flex: p1Wins == 0 && p2Wins == 0 ? 1 : (p2Wins == 0 ? 1 : p2Wins),
                            child: Container(height: 6, color: Colors.blue),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            if (matches.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Column(
                    children: [
                      Icon(Iconsax.clock, color: Colors.white12, size: 40),
                      SizedBox(height: 12),
                      Text(
                        'No previous matches',
                        style: TextStyle(color: Colors.white38),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              const Text(
                'PREVIOUS MATCHES',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 11,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 12),
              ...matches.map((m) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: MatchCard(
                  match: m,
                  onTap: () => Get.to(() => MatchDetailScreen(match: m)),
                ),
              )),
            ],
          ],
        );
      },
    );
  }
}