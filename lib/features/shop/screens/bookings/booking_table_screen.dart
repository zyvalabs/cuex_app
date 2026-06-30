import 'package:cuex_app/features/shop/screens/bookings/widgets/slot_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../common/widgets/date/date_selector.dart';
import '../../../../common/widgets/sports/sports_grid.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';

import '../../controllers/book_table_controller.dart';
import '../../controllers/slot_controller.dart';
import '../../controllers/table/table_controller.dart';
import '../../controllers/venue_controller.dart';
import '../../models/venue_model.dart';
import '../table/widgets/compacy_table_card.dart';
import 'bookig_confirmation_screen.dart';

class BookTableScreen extends StatelessWidget {
  const BookTableScreen({super.key, required this.venue});

  final VenueModel venue;

  @override
  Widget build(BuildContext context) {
    final bookController = Get.put(BookTableController());
    final venueController = VenueController.instance;
    venueController.fetchVenueSports(venue.sportIds);
    final tableController = Get.put(TableController());
    tableController.fetchVenueTables(venue.id);
    final slotController = Get.put(SlotController());

    return Scaffold(
      backgroundColor: TColors.peppercorn,
      appBar: TAppBar(
        showBackArrow: true,
        title: Text(venue.name, style: Theme.of(context).textTheme.headlineMedium),
        showActions: false,
        showSkipButton: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Date', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: TSizes.spaceBtwItems),
            const DateSelector(),
            const SizedBox(height: TSizes.spaceBtwSections),
            Text('Select Sport', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: TSizes.spaceBtwItems),
            Obx(() => venueController.venueSports.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : SportsGrid(
              sports: venueController.venueSports,
              selectedSportIds: bookController.selectedSportId.value.isNotEmpty
                  ? [bookController.selectedSportId.value]
                  : [],
              onTap: (sport) => bookController.selectSport(sport.id),
            )),
            const SizedBox(height: TSizes.spaceBtwSections),
            Text('Select Table', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: TSizes.spaceBtwItems),
            Obx(() => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: tableController.tables.map((table) {
                  final isSelected = bookController.selectedTableId.value == table.id;
                  return Padding(
                    padding: const EdgeInsets.only(right: TSizes.sm),
                    child: CompactTableCard(
                      table: table,
                      isSelected: isSelected,
                      onTap: () => bookController.selectTable(table.id),
                    ),
                  );
                }).toList(),

              ),

            )),
            const SizedBox(height: TSizes.spaceBtwItems),
            Obx(() => bookController.selectedTableId.value.isNotEmpty
                ? SlotPickerWidget(
              slotController: Get.find<SlotController>(),
              bookController: bookController,
            )
                : const SizedBox.shrink()),


          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Obx(() => ElevatedButton(
          onPressed: bookController.selectedSlotIds.isEmpty ? null : () => Get.to(() => BookingConfirmScreen(
            venue: venue,
            table: TableController.instance.tables.firstWhere((t) => t.id == bookController.selectedTableId.value),
            slots: SlotController.instance.slots.where((s) => bookController.selectedSlotIds.contains(s.startTime)).toList(),
            date: bookController.selected.value,
            sportId: bookController.selectedSportId.value,
          )),
          child: const Text('Next'),
        )),
      ),
    );
  }
}