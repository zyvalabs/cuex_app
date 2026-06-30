import 'package:cuex_app/features/shop/screens/venues/widgets/venue_filter_chips.dart';
import 'package:cuex_app/features/shop/screens/venues/widgets/venue_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../utils/constants/sizes.dart';
import '../../controllers/venue_controller.dart';
import 'add_edit_venue.dart';
class VenueListScreen extends StatelessWidget {
  const VenueListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = VenueController.instance;
    final search = ''.obs;
    final selectedFilter = 'All'.obs;

    return Scaffold(
      appBar: AppBar(title: const Text('All Venues')),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: ElevatedButton.icon(
          onPressed: () => Get.to(() => const AddEditVenueScreen()),
          icon: const Icon(Iconsax.add),
          label: const Text('Add Venue'),
          style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(TSizes.defaultSpace),
            child: TextField(
              onChanged: (val) => search.value = val.toLowerCase(),
              decoration: InputDecoration(
                hintText: 'Search venues...',
                prefixIcon: const Icon(Iconsax.search_normal, size: 18),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(TSizes.cardRadiusMd), borderSide: BorderSide(color: Colors.grey.withOpacity(0.2))),
                contentPadding: const EdgeInsets.symmetric(horizontal: TSizes.md, vertical: TSizes.sm),
              ),
            ),
          ),
          VenueFilterChips(
            selected: selectedFilter,
            onSelected: (val) => selectedFilter.value = val,
          ),
          const SizedBox(height: TSizes.spaceBtwItems),
          Expanded(
            child: Obx(() {
              var filtered = controller.allVenues.where((v) => v.name.toLowerCase().contains(search.value)).toList();

              if (selectedFilter.value == 'Active') filtered = filtered.where((v) => v.isActive).toList();
              if (selectedFilter.value == 'Inactive') filtered = filtered.where((v) => !v.isActive).toList();
              if (selectedFilter.value == 'Featured') filtered = filtered.where((v) => v.isFeatured).toList();
              if (selectedFilter.value == 'Streaming') filtered = filtered.where((v) => v.streamingEnabled).toList();

              if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
              if (filtered.isEmpty) return const Center(child: Text('No venues found'));

              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: TSizes.spaceBtwItems),
                itemBuilder: (_, i) => VenueListTile(venue: filtered[i], onTap: () {}),
              );
            }),
          ),
        ],
      ),

    );


  }
}