import 'package:cuex_app/features/shop/screens/table/widgets/action_buttons.dart';
import 'package:cuex_app/features/shop/screens/table/widgets/slots_management.dart';
import 'package:cuex_app/features/shop/screens/table/widgets/table_info_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../controllers/slot_controller.dart';

import '../../controllers/table/table_controller.dart';
import '../../controllers/table/table_model.dart';
import '../../controllers/venue_controller.dart';

class TableDetailScreen extends StatefulWidget {
  const TableDetailScreen({super.key, required this.table});
  final TableModel table;

  @override
  State<TableDetailScreen> createState() => _TableDetailScreenState();
}

class _TableDetailScreenState extends State<TableDetailScreen> {
  late SlotController slotController;

  @override
  void initState() {
    slotController = Get.put(SlotController());
    final venue = VenueController.instance.venue.value;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      slotController.generateSlots(table: widget.table, venue: venue, date: DateTime.now());
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.peppercorn,
      appBar: TAppBar(
        showBackArrow: true,
        title: Text(widget.table.tableName, style: Theme.of(context).textTheme.headlineMedium),
        showActions: false,
        showSkipButton: false,
      ),
      bottomNavigationBar: SaveSlotsButton(slotController: slotController),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TableInfoCard(table: widget.table),
            const SizedBox(height: TSizes.spaceBtwItems),
            ActionButtons(table: widget.table, onDelete: () => _confirmDelete(context)),
            const SizedBox(height: TSizes.spaceBtwSections),
            SlotManagementSection(slotController: slotController, context: context),
            const SizedBox(height: TSizes.spaceBtwSections),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Delete Table', style: TextStyle(color: Colors.white)),
        content: Text('Are you sure you want to delete ${widget.table.tableName}?', style: const TextStyle(color: Colors.grey)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.find<TableController>().deleteTable(widget.table.id, widget.table.venueId);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
