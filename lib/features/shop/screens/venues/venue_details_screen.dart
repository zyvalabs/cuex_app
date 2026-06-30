import 'package:cuex_app/features/shop/screens/venues/widgets/venue_image_slider.dart';
import 'package:cuex_app/features/shop/screens/venues/widgets/venue_meta_data.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../common/widgets/sports/sports_grid.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/popups/loaders.dart';
import '../../controllers/venue_controller.dart';
import '../../models/venue_model.dart';

class VenueDetailScreen extends StatefulWidget {
  const VenueDetailScreen({super.key, required this.venue});
  final VenueModel venue;

  @override
  State<VenueDetailScreen> createState() => _VenueDetailScreenState();
}

class _VenueDetailScreenState extends State<VenueDetailScreen> {
  @override
  void initState() {
    super.initState();
    VenueController.instance.fetchVenueSports(widget.venue.sportIds);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TVenueImageSlider(venue: widget.venue),
            Padding(
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TVenueMetaData(venue: widget.venue),
                  const SizedBox(height: TSizes.spaceBtwSections),

                  // About
                  Text('About', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: TSizes.spaceBtwItems / 2),
                  Text(
                    widget.venue.description.isNotEmpty ? widget.venue.description : 'No description available.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: TSizes.spaceBtwSections),

                  // Address
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: TSizes.md, vertical: TSizes.sm),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.withOpacity(0.2)),
                            borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
                          ),
                          child: Row(
                            children: [
                              const Icon(Iconsax.location, size: 16, color: Colors.grey),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  widget.venue.address.isNotEmpty ? widget.venue.address : widget.venue.city,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () async {
                                  final lat = widget.venue.location.latitude;
                                  final lng = widget.venue.location.longitude;
                                  final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
                                  if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: TColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(TSizes.cardRadiusSm),
                                  ),
                                  child: const Icon(Iconsax.directbox_send, size: 16, color: TColors.primary),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: TSizes.spaceBtwSections),

                  // Sports
                  Text('Sports', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  Obx(() {
                    final sports = VenueController.instance.venueSports;
                    if (sports.isEmpty) return const SizedBox.shrink();
                    return SportsGrid(sports: sports, selectedSportIds: const []);
                  }),
                  const SizedBox(height: TSizes.defaultSpace),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Row(
          children: [
            // Expanded(
            //   child: ElevatedButton.icon(
            //     onPressed: () => Get.to(() => BookTableScreen(venue: widget.venue)),
            //     icon: const Icon(Iconsax.calendar_tick, size: 18),
            //     label: const Text('Book Table'),
            //     style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
            //   ),
            // ),
            // const SizedBox(width: TSizes.spaceBtwItems),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () async {
                  final phone = widget.venue.phone;
                  if (phone != null && phone.isNotEmpty) {
                    final uri = Uri(scheme: 'tel', path: phone);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    }
                  } else {
                    TLoaders.warningSnackBar(title: 'No Contact', message: 'No phone number available for this venue');
                  }
                },
                icon: const Icon(Iconsax.call, size: 18),
                label: const Text('Contact Venue'),
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}