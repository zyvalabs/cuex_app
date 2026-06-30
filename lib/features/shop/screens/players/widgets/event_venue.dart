import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../data/repositories/venue/venue_repository.dart';

import '../../venues/widgets/compact_venue_card.dart';

class EventVenueWidget extends StatelessWidget {
  const EventVenueWidget({super.key, required this.venueId});

  final String venueId;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Get.put(VenueRepository()).fetchVenueById(venueId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 80,
            child: Center(child: CircularProgressIndicator(color: Colors.red)),
          );
        }
        if (!snapshot.hasData) return const SizedBox();

        return CompactVenueCard(venue: snapshot.data!);
      },
    );
  }
}