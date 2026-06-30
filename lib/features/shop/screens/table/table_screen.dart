
// tables_screen.dart
import 'package:cuex_app/features/shop/screens/table/widgets/table_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../routes/routes.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../controllers/table/table_controller.dart';

import '../../models/venue_model.dart';
import 'add_table_screen.dart';
class TablesScreen extends StatefulWidget {
  const TablesScreen({super.key, required this.venue});
  final VenueModel venue;

  @override
  State<TablesScreen> createState() => _TablesScreenState();
}

class _TablesScreenState extends State<TablesScreen> {
  late TableController controller;

  @override
  void initState() {
    Get.lazyPut(() => TableController(), fenix: true);
    controller = Get.find<TableController>();
    print('🏢 TablesScreen venue: ${widget.venue.id}');
    controller.fetchVenueTables(widget.venue.id);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.peppercorn,
      appBar: TAppBar(
        showBackArrow: true,
        title: Text('Tables', style: Theme.of(context).textTheme.headlineMedium),
        showActions: false,
        showSkipButton: false,
      ),
      body: Obx(() => controller.isLoading.value
          ? const Center(child: CircularProgressIndicator())
          : controller.tables.isEmpty
          ? const Center(child: Text('No tables added yet', style: TextStyle(color: Colors.grey)))
          : ListView.separated(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        itemCount: controller.tables.length,
        separatorBuilder: (_, __) => const SizedBox(height: TSizes.spaceBtwItems),
        itemBuilder: (_, index) => TableCard(
          table: controller.tables[index],
          onTap: () => Get.toNamed(TRoutes.tableDetail, arguments: controller.tables[index]),
        ),
      )),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: ElevatedButton.icon(
          onPressed: () async {
            await Get.to(() => AddTableScreen(venueId: widget.venue.id));
            controller.fetchVenueTables(widget.venue.id);
            print('🏢 TablesScreen venue id: ${widget.venue.id}');
          },
          icon: const Icon(Iconsax.add),
          label: const Text('Add Table'),
        ),
      ),
    );
  }
}