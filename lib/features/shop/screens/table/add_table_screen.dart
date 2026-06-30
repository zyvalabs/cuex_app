import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../common/widgets/sports/sports_grid.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../controllers/table/add_table_controller.dart';
import '../../controllers/table/table_model.dart';
import '../../controllers/venue_controller.dart';

class AddTableScreen extends StatelessWidget {
  const AddTableScreen({super.key, required this.venueId, this.table});

  final String venueId;
  final TableModel? table;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddTableController());
    final venueController = VenueController.instance;

    return Scaffold(
      backgroundColor: TColors.peppercorn,
      appBar: TAppBar(
        showBackArrow: true,
        title: Text('Add Table', style: Theme.of(context).textTheme.headlineMedium),
        showActions: false,
        showSkipButton: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Form(
          key: controller.addTableFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// Table Name
              TextFormField(
                controller: controller.tableName,
                decoration: const InputDecoration(
                  labelText: 'Table Name',
                  prefixIcon: Icon(Iconsax.grid_1),
                ),
                validator: (v) => v!.isEmpty ? 'Enter table name' : null,
              ),
              const SizedBox(height: TSizes.spaceBtwSections),

              /// Select Sport
              Text('Select Sport', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: TSizes.spaceBtwItems),
              Obx(() {
                if (venueController.venueSports.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                return SportsGrid(
                  sports: venueController.venueSports,
                  selectedSportIds: controller.selectedSportIds.toList(),
                  multiSelect: true,
                  onTap: (sport) => controller.onSportSelected(sport),
                );
              }),
              const SizedBox(height: TSizes.spaceBtwSections),

              // /// Select Table Type
              // Obx(() {
              //   if (controller.availableTableTypes.isEmpty) return const SizedBox.shrink();
              //   return Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       Text('Table Type', style: Theme.of(context).textTheme.headlineSmall),
              //       const SizedBox(height: TSizes.spaceBtwItems),
              //       Wrap(
              //         spacing: TSizes.sm,
              //         runSpacing: TSizes.sm,
              //         children: controller.availableTableTypes.map((type) {
              //           final isSelected = controller.selectedTableType.value == type;
              //           return GestureDetector(
              //             onTap: () => controller.onTableTypeSelected(type),
              //             child: AnimatedContainer(
              //               duration: const Duration(milliseconds: 200),
              //               padding: const EdgeInsets.symmetric(horizontal: TSizes.md, vertical: TSizes.sm),
              //               decoration: BoxDecoration(
              //                 color: isSelected ? TColors.primary.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
              //                 borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
              //                 border: Border.all(color: isSelected ? TColors.primary : Colors.transparent),
              //               ),
              //               child: Text(
              //                 type.name.capitalizeFirst!,
              //                 style: TextStyle(color: isSelected ? TColors.primary : Colors.white),
              //               ),
              //             ),
              //           );
              //         }).toList(),
              //       ),
              //       const SizedBox(height: TSizes.spaceBtwSections),
              //     ],
              //   );
              // }),

              // /// Max Players
              // TextFormField(
              //   controller: controller.maxPlayers,
              //   keyboardType: TextInputType.number,
              //   decoration: const InputDecoration(
              //     labelText: 'Max Players',
              //     prefixIcon: Icon(Iconsax.people),
              //   ),
              //   validator: (v) => v!.isEmpty ? 'Enter max players' : null,
              // ),
              // const SizedBox(height: TSizes.spaceBtwInputFields),

              /// Brand (Optional)
              TextFormField(
                controller: controller.brand,
                decoration: const InputDecoration(
                  labelText: 'Brand (Optional)',
                  prefixIcon: Icon(Iconsax.tag),
                ),
              ),
              const SizedBox(height: TSizes.spaceBtwSections),

              /// Save Button
              Obx(() => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () => controller.saveTable(venueId, context),
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator()
                      : const Text('Add Table'),
                ),
              )),

              const SizedBox(height: TSizes.spaceBtwSections),
            ],
          ),
        ),
      ),
    );
  }
}