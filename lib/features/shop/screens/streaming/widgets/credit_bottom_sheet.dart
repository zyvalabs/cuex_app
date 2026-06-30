import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../utils/constants/enums.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/popups/loaders.dart';

import '../../../controllers/streaming_credit_controller.dart';
import '../../../controllers/user_list_controller.dart';
import '../../../controllers/venue_controller.dart';
import '../../users/widgets/search_bar.dart';
import '../../users/widgets/user_avatar_widget.dart';

class AddCreditsBottomSheet extends StatelessWidget {
  const AddCreditsBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => const AddCreditsBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final creditsController = Get.find<StreamingCreditsController>();
    final venueController = VenueController.instance;
    final adminController = Get.isRegistered<AdminUserController>()
        ? Get.find<AdminUserController>()
        : Get.put(AdminUserController(roleFilter: AppRole.player));

    final searchController = TextEditingController();
    final creditsCountController = TextEditingController();
    final amountController = TextEditingController();
    final paymentRefController = TextEditingController();
    final selectedType = 'venue'.obs;
    final selectedId = ''.obs;
    final selectedName = ''.obs;
    final search = ''.obs;

    return Padding(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Handle bar
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(99)),
              ),
            ),

            Text('Add Credits', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: TSizes.spaceBtwItems),

            // Type selector
            Obx(() => Row(
              children: ['venue', 'player'].map((type) {
                final isSelected = selectedType.value == type;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      selectedType.value = type;
                      selectedId.value = '';
                      selectedName.value = '';
                      search.value = '';
                      searchController.clear();
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: type == 'venue' ? 8 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.transparent,
                        border: Border.all(
                          color: isSelected ? Theme.of(context).primaryColor : Colors.grey.withOpacity(0.3),
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
                      ),
                      child: Center(
                        child: Text(
                          type == 'venue' ? 'Venue' : 'Player',
                          style: TextStyle(
                            color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            )),
            const SizedBox(height: TSizes.spaceBtwItems),

            // Search bar
            TSearchBar(
              controller: searchController,
              hint: 'Search by name...',
              onChanged: (val) => search.value = val.toLowerCase(),
            ),
            const SizedBox(height: TSizes.spaceBtwItems),

            // Search results
            Obx(() {
              final isVenue = selectedType.value == 'venue';
              if (isVenue) {
                final filtered = venueController.allVenues
                    .where((v) => v.name.toLowerCase().contains(search.value))
                    .take(5)
                    .toList();
                if (filtered.isEmpty) return const Text('No venues found', style: TextStyle(color: Colors.grey, fontSize: 13));
                return Column(
                  children: filtered.map((v) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Iconsax.building),
                    title: Text(v.name, style: Theme.of(context).textTheme.bodyMedium),
                    subtitle: Text(v.city, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    trailing: Obx(() => selectedId.value == v.id
                        ? Icon(Iconsax.tick_circle5, color: Theme.of(context).primaryColor)
                        : const SizedBox.shrink()),
                    onTap: () {
                      selectedId.value = v.id;
                      selectedName.value = v.name;
                    },
                  )).toList(),
                );
              } else {
                final filtered = adminController.users
                    .where((u) => u.fullName.toLowerCase().contains(search.value) || u.email.toLowerCase().contains(search.value))
                    .take(5)
                    .toList();
                if (filtered.isEmpty) return const Text('No players found', style: TextStyle(color: Colors.grey, fontSize: 13));
                return Column(
                  children: filtered.map((u) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: UserAvatarWidget(imageUrl: u.profilePicture, fullName: u.fullName, radius: 18),
                    title: Text(u.fullName, style: Theme.of(context).textTheme.bodyMedium),
                    subtitle: Text(u.email, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    trailing: Obx(() => selectedId.value == u.id
                        ? Icon(Iconsax.tick_circle5, color: Theme.of(context).primaryColor)
                        : const SizedBox.shrink()),
                    onTap: () {
                      selectedId.value = u.id;
                      selectedName.value = u.fullName;
                    },
                  )).toList(),
                );
              }
            }),
            const SizedBox(height: TSizes.spaceBtwItems),

            // Selected display
            Obx(() => selectedName.value.isNotEmpty
                ? Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: TSizes.md, vertical: TSizes.sm),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
                border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Iconsax.tick_circle5, size: 16, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 8),
                  Text('Selected: ${selectedName.value}', style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 13)),
                ],
              ),
            )
                : const SizedBox.shrink()),
            const SizedBox(height: TSizes.spaceBtwItems),

            // Credits count
            TextField(
              controller: creditsCountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Number of Credits *', prefixIcon: Icon(Iconsax.video_play, size: 18)),
            ),
            const SizedBox(height: TSizes.spaceBtwInputFields),

            // Amount
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Amount Paid (₹)', prefixIcon: Icon(Iconsax.money, size: 18), prefixText: '₹ '),
            ),
            const SizedBox(height: TSizes.spaceBtwInputFields),

            // Payment ref
            TextField(
              controller: paymentRefController,
              decoration: const InputDecoration(labelText: 'Payment Reference (UPI/Cash)', prefixIcon: Icon(Iconsax.receipt_2, size: 18)),
            ),
            const SizedBox(height: TSizes.spaceBtwSections),

            // Confirm button
            Obx(() => SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedId.value.isEmpty
                    ? null
                    : () async {
                  final credits = int.tryParse(creditsCountController.text.trim());
                  if (credits == null || credits <= 0) {
                    TLoaders.warningSnackBar(title: 'Invalid', message: 'Enter a valid credit count');
                    return;
                  }
                  await creditsController.purchaseCredits(
                    id: selectedId.value,
                    creditCount: credits,
                    amount: double.tryParse(amountController.text.trim()) ?? 0,
                    paymentRef: paymentRefController.text.trim(),
                    note: 'Added by admin for ${selectedName.value}',
                  );
                  if (context.mounted) Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                child: const Text('Add Credits'),
              ),
            )),
          ],
        ),
      ),
    );
  }
}