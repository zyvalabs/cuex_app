import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../common/widgets/matches/card/match_card.dart';
import '../../../../../data/repositories/matches/matches_repository.dart';
import '../../../../../utils/constants/enums.dart';
import '../../../../personalization/controllers/user_controller.dart';
import '../../../controllers/matches_controller.dart';
import '../../../models/match_model.dart';
import '../../live_scroring/live_scoring.dart';

import '../../matches/match_detail.dart';

class EventMatchesWidget extends StatefulWidget {
  const EventMatchesWidget({super.key, required this.eventId});
  final String eventId;

  @override
  State<EventMatchesWidget> createState() => _EventMatchesWidgetState();
}

class _EventMatchesWidgetState extends State<EventMatchesWidget> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MatchModel>>(
      future: Get.put(MatchRepository()).fetchMatchesByEvent(widget.eventId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.red));
        }

        final all = snapshot.data ?? [];
        final filtered = _filter == 'all'
            ? all
            : all.where((m) => m.matchStatus == _filter).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['all', 'live', 'upcoming', 'completed']
                    .map((f) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _filter = f),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: _filter == f
                            ? Colors.red
                            : Colors.white10,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        f.toUpperCase(),
                        style: TextStyle(
                          color: _filter == f
                              ? Colors.white
                              : Colors.white54,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 12),

            // Match list
            if (filtered.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF141414),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Iconsax.cup, color: Colors.white12, size: 20),
                    SizedBox(width: 10),
                    Text('No matches',
                        style: TextStyle(color: Colors.white38)),
                  ],
                ),
              )
            else
              ...filtered.map((m) {
                final role = UserController.instance.user.value.role;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: MatchCard(
                    match: m,
                    onTap: () {
                      Get.put(MatchController()); // ensure registered
                      if (role == AppRole.admin || role == AppRole.partner) {
                        Get.to(() => LiveScoringScreen(match: m));
                      } else {
                        Get.to(() => MatchDetailScreen(match: m));
                      }
                    },
                  ),
                );
              }),
          ],
        );
      },
    );
  }
}