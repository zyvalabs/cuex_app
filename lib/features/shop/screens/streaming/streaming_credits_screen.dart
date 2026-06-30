import 'package:cuex_app/features/shop/screens/streaming/widgets/credit_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../../utils/constants/enums.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../personalization/controllers/user_controller.dart';

import '../../controllers/streaming_credit_controller.dart';
import '../../controllers/venue_controller.dart';

class StreamingCreditsScreen extends StatefulWidget {
  const StreamingCreditsScreen({super.key});

  @override
  State<StreamingCreditsScreen> createState() => _StreamingCreditsScreenState();
}

class _StreamingCreditsScreenState extends State<StreamingCreditsScreen> {
  late final StreamingCreditsController creditsController;
  late final String _id;
  late final AppRole _role;

  @override
  void initState() {
    super.initState();
    creditsController = Get.isRegistered<StreamingCreditsController>()
        ? Get.find<StreamingCreditsController>()
        : Get.put(StreamingCreditsController());

    _role = UserController.instance.user.value.role;

    // Use venueId for partner, userId for player, venueId for admin (default)
    if (_role == AppRole.partner) {
      _id = VenueController.instance.venue.value.id;
    } else {
      _id = UserController.instance.user.value.id;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      creditsController.fetchCredits(_id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Streaming Credits')),
      body: Obx(() {
        if (creditsController.isLoading.value) return const Center(child: CircularProgressIndicator());

        final credits = creditsController.credits.value;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Credits Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(TSizes.lg),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Iconsax.video_play, color: Colors.white, size: 32),
                    const SizedBox(height: TSizes.sm),
                    Text(
                      '${credits?.remainingCredits ?? 0}',
                      style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold),
                    ),
                    const Text('Matches Remaining', style: TextStyle(color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: TSizes.md),

                    // Progress bar
                    if (credits != null && credits.totalCredits > 0) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          value: credits.remainingCredits / credits.totalCredits,
                          backgroundColor: Colors.white24,
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${credits.usedCredits} used', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                          Text('${credits.totalCredits} total purchased', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: TSizes.spaceBtwSections),

              // Contact admin message for partner/player
              if (_role != AppRole.admin)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(TSizes.md),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                    borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
                  ),
                  child: Row(
                    children: [
                      const Icon(Iconsax.info_circle, size: 18, color: Colors.grey),
                      const SizedBox(width: TSizes.sm),
                      Expanded(
                        child: Text(
                          'Contact admin to purchase more streaming credits.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),

              // Admin — Add Credits button placeholder
              if (_role == AppRole.admin) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => AddCreditsBottomSheet.show(context),
                    icon: const Icon(Iconsax.add, size: 18),
                    label: const Text('Add Credits'),
                    style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                  ),
                ),
              ],
              const SizedBox(height: TSizes.spaceBtwSections),

              // Transaction History
              Text('Transaction History', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: TSizes.spaceBtwItems),

              if (credits == null || credits.transactions.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(TSizes.defaultSpace),
                    child: Text('No transactions yet', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey)),
                  ),
                )
              else
                ...credits.transactions.reversed.map((t) {
                  final date = t['purchasedAt'] != null
                      ? DateFormat('dd MMM yyyy').format((t['purchasedAt'] as dynamic).toDate())
                      : '—';
                  return Container(
                    margin: const EdgeInsets.only(bottom: TSizes.spaceBtwItems),
                    padding: const EdgeInsets.all(TSizes.md),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.withOpacity(0.15)),
                      borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Iconsax.video_play, size: 18, color: Theme.of(context).primaryColor),
                        ),
                        const SizedBox(width: TSizes.spaceBtwItems),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t['note'] ?? 'Credits purchased',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              Text(date, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '+${t['credits']} credits',
                              style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                            if (t['amount'] != null && t['amount'] > 0)
                              Text('₹${t['amount']}', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        );
      }),
    );
  }
}