import 'package:cuex_app/features/shop/screens/events/widgets/event_participation_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../../../common/widgets/appbar/appbar.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';

import '../../../../data/repositories/events/event_repository.dart';
import '../../../personalization/controllers/user_controller.dart';
import '../../controllers/event_registration_controller.dart';
import '../../models/event_model.dart';
import '../../models/event_participant_model.dart';
import '../event_particapnts/widgets/particapant_status_badge.dart';
import '../events/widgets/event_status_badge.dart';

import '../event_particapnts/widgets/payment_status_badge.dart';
import 'event_details.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../common/widgets/appbar/appbar.dart';
import '../../../../../common/widgets/shimmers/shimmer.dart';


class MyEventsScreen extends StatefulWidget {
  const MyEventsScreen({super.key});

  @override
  State<MyEventsScreen> createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen> {
  final controller = Get.put(EventParticipantController());
  final Map<String, EventModel> _eventCache = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final userId = UserController.instance.user.value.id;
      await controller.fetchUserParticipations(userId);
      await Future.wait(controller.userParticipations.map((p) async {
        if (!_eventCache.containsKey(p.eventId)) {
          try {
            final event =
            await EventRepository.instance.fetchSingleItem(p.eventId);
            _eventCache[p.eventId] = event;
          } catch (_) {}
        }
      }));
    } catch (_) {} finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.peppercorn,
      appBar: TAppBar(
        showBackArrow: true,
        showActions: false,
        showSkipButton: false,
        title: Text(
          'My Events',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      body: _isLoading
          ? const _MyEventsShimmer()
          : Obx(() {
        final participations = controller.userParticipations;

        // ── Empty ───────────────────────
        if (participations.isEmpty) {
          return RefreshIndicator(
            onRefresh: _load,
            color: TColors.june,
            backgroundColor: const Color(0xFF1A1A1A),
            child: ListView(
              children: [
                SizedBox(
                  height: 400,
                  child: Center(
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
                            Iconsax.calendar,
                            size: 28,
                            color: Colors.white24,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'No Events Yet',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Register for events to see them here',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.3),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // ── List ────────────────────────
        return RefreshIndicator(
          onRefresh: _load,
          color: TColors.june,
          backgroundColor: const Color(0xFF1A1A1A),
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(
              TSizes.defaultSpace,
              TSizes.defaultSpace,
              TSizes.defaultSpace,
              100,
            ),
            itemCount: participations.length,
            itemBuilder: (_, i) => EventParticipationCard(
              participation: participations[i],
              event: _eventCache[participations[i].eventId],
              isLast: i == participations.length - 1,
            ),
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────
// Shimmer
// ─────────────────────────────────────────────

class _MyEventsShimmer extends StatelessWidget {
  const _MyEventsShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(TSizes.defaultSpace),
      itemCount: 6,
      itemBuilder: (_, i) => Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: i < 5
              ? Border(
            bottom: BorderSide(
              color: Colors.white.withOpacity(0.06),
            ),
          )
              : null,
        ),
        child: Row(
          children: [
            TShimmerEffect(width: 48, height: 48, radius: 10),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TShimmerEffect(
                      width: double.infinity, height: 13, radius: 4),
                  const SizedBox(height: 5),
                  TShimmerEffect(width: 100, height: 10, radius: 4),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      TShimmerEffect(width: 60, height: 16, radius: 99),
                      const SizedBox(width: 6),
                      TShimmerEffect(width: 50, height: 16, radius: 99),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            TShimmerEffect(width: 40, height: 20, radius: 4),
          ],
        ),
      ),
    );
  }
}