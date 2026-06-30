import 'package:cuex_app/features/shop/screens/matches/widgets/player_selected_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../../common/widgets/sports/sports_grid.dart';
import '../../../../../utils/constants/enums.dart';
import '../../../../../utils/constants/sizes.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../personalization/controllers/user_controller.dart';
import '../../controllers/create_match_controller.dart';
import '../../controllers/venue_controller.dart';
import '../../models/match_model.dart';
import 'widgets/frame_selector.dart';
import 'widgets/live_stream_toggle.dart';
import 'widgets/match_date_time_picker.dart';

class CreateMatchScreen extends StatefulWidget {
  final String eventId;
  final MatchModel? existingMatch;
  final bool isPractice;
  final String? prefilledSportId;

  const CreateMatchScreen({
    super.key,
    this.eventId = '',
    this.existingMatch,
    this.isPractice = false,
    this.prefilledSportId,

  });

  @override
  State<CreateMatchScreen> createState() => _CreateMatchScreenState();
}

class _CreateMatchScreenState extends State<CreateMatchScreen> {
  late final CreateMatchController controller;
  late final AppRole role;

  @override
  void initState() {
    super.initState();
    controller = Get.put(
      CreateMatchController(
        eventId: widget.eventId,
        existingMatch: widget.existingMatch,
        isPractice: widget.isPractice,
      ),
      tag: widget.existingMatch?.id ?? 'new_${widget.isPractice ? 'practice' : 'tournament'}',
    );
    final role = UserController.instance.user.value.role;
    print('🎮 Role: $role isPractice: ${widget.isPractice}');
    if (widget.prefilledSportId != null) {
      controller.selectedSportId.value = widget.prefilledSportId;
    }

    // Fetch all sports for sport selector
    VenueController.instance.fetchAllSports();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TAppBar(
        showBackArrow: true,
        showActions: false,
        showSkipButton: false,
        title: Text(
          controller.isEditMode
              ? 'Edit Match'
              : widget.isPractice
              ? 'Practice Match'
              : 'Create Match',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Practice badge
              if (widget.isPractice) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(TSizes.md),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
                    border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(Iconsax.timer_1, size: 18, color:  Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        'Practice match',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: TSizes.spaceBtwItems),
              ],

              // Round Name — only for tournament
              if (!widget.isPractice) ...[
                TextFormField(
                  controller: controller.roundNameController,
                  decoration: const InputDecoration(
                    labelText: 'Round Name *',
                    hintText: 'e.g. Quarter Finals, Semi Finals',
                    prefixIcon: Icon(Iconsax.tag),
                  ),
                  validator: (value) {
                    if (!widget.isPractice && (value == null || value.isEmpty)) return 'Please enter round name';
                    return null;
                  },
                ),
                const SizedBox(height: TSizes.spaceBtwItems),
              ],

              // Total Frames
              Text('Total Frames (Best of) *', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: TSizes.sm),
              FrameSelector(
                frames: controller.totalFrames,
                onChanged: (val) => controller.totalFrames.value = val,
              ),
              const SizedBox(height: TSizes.spaceBtwSections),

              // Players
              Text('Players', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: TSizes.spaceBtwItems),

              // Player 1
              Obx(() => PlayerSelectCard(
                label: 'Player 1',
                playerId: controller.player1Id.value,
                playerName: controller.player1Name.value,
                isAutoFilled: widget.isPractice,
                onTap: widget.isPractice
                    ? () {}
                    : () => controller.selectPlayer(context, isPlayer1: true),
              )),
              const SizedBox(height: TSizes.spaceBtwItems),

              // Player 2
              if (widget.isPractice) ...[
                // QR Scan or manual entry for practice
                Obx(() => controller.player2Name.value != null
                    ? PlayerSelectCard(
                  label: 'Player 2',
                  playerId: controller.player2Id.value,
                  playerName: controller.player2Name.value,
                  onTap: () => _showPlayer2Options(context),
                )
                    : _buildPlayer2Options(context)),
              ] else ...[
                // Event participant selector for tournament
                Obx(() => PlayerSelectCard(
                  label: 'Player 2',
                  playerId: controller.player2Id.value,
                  playerName: controller.player2Name.value,
                  onTap: () => controller.selectPlayer(context, isPlayer1: false),
                )),
              ],
              const SizedBox(height: TSizes.spaceBtwSections),

              // Sport selector — always show
// Sport selector — hide if prefilled from event
              if (widget.prefilledSportId == null) ...[
                Text('Sport', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: TSizes.spaceBtwItems),
                Obx(() {
                  final sports = VenueController.instance.allSports;
                  if (sports.isEmpty) return const Center(child: CircularProgressIndicator());
                  return SportsGrid(
                    sports: sports,
                    selectedSportIds: controller.selectedSportId.value != null
                        ? [controller.selectedSportId.value!]
                        : [],
                    onTap: (sport) => controller.selectSport(sport.id, sport.name),
                  );
                }),
                const SizedBox(height: TSizes.spaceBtwSections),
              ],

              // Scheduled Time
              Text('Scheduled Time', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: TSizes.spaceBtwItems),
              MatchDateTimePicker(
                dateTime: controller.scheduledTime,
                onTap: () => controller.selectDateTime(context),
              ),
              const SizedBox(height: TSizes.spaceBtwSections),

              // Live Stream Toggle
              LiveStreamToggle(
                enabled: controller.enableLiveStream,
                onChanged: (val) => controller.enableLiveStream.value = val,
              ),
              const SizedBox(height: TSizes.spaceBtwSections),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => controller.isEditMode
                      ? controller.updateMatch(context)
                      : controller.createMatch(context),
                  icon: Icon(controller.isEditMode ? Iconsax.edit : Iconsax.tick_circle, size: 18),
                  label: Text(controller.isEditMode ? 'Update Match' : 'Create Match'),
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 52)),
                ),
              ),
              const SizedBox(height: TSizes.defaultSpace),
            ],
          ),
        ),
      ),
    );
  }

  /// Player 2 options for practice — QR or manual
  Widget _buildPlayer2Options(BuildContext context) {
    return Column(
      children: [
        // QR Scan
        GestureDetector(
          onTap: () => _openQRScanner(context),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(TSizes.md),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
              borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
                  ),
                  child: const Icon(Iconsax.scan, size: 20, color: Colors.white),
                ),
                const SizedBox(width: TSizes.spaceBtwItems),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Scan Player QR Code', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                      Text('Scan opponent\'s CueX profile QR', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey)),
                    ],
                  ),
                ),
                const Icon(Iconsax.arrow_right_3, size: 16, color: Colors.grey),
              ],
            ),
          ),
        ),
        const SizedBox(height: TSizes.spaceBtwItems),

        // Manual entry
        TextFormField(
          controller: controller.player2NameController,
          decoration: const InputDecoration(
            labelText: 'Or enter opponent name manually',
            prefixIcon: Icon(Iconsax.user_edit, size: 18),
          ),
          onChanged: (val) {
            if (val.trim().isNotEmpty) controller.setPlayer2ByName(val.trim());
          },
        ),
      ],
    );
  }

  /// Show player 2 change options
  void _showPlayer2Options(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Iconsax.scan),
              title: const Text('Scan QR Code'),
              onTap: () {
                Navigator.pop(context);
                _openQRScanner(context);
              },
            ),
            ListTile(
              leading: const Icon(Iconsax.user_edit),
              title: const Text('Enter Name Manually'),
              onTap: () {
                Navigator.pop(context);
                controller.player2Name.value = null;
                controller.player2Id.value = null;
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Open QR scanner
  void _openQRScanner(BuildContext context) {
    Get.to(() => _QRScannerScreen(
      onScanned: (userId) => controller.setPlayer2FromQR(userId),
    ));
  }
}

/// Simple QR Scanner screen using mobile_scanner
class _QRScannerScreen extends StatelessWidget {
  const _QRScannerScreen({required this.onScanned});
  final void Function(String userId) onScanned;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Player QR')),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) {
              final barcode = capture.barcodes.firstOrNull;
              if (barcode?.rawValue != null) {
                onScanned(barcode!.rawValue!);
                Get.back();
              }
            },
          ),
          // Overlay guide
          Center(
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: const Center(
              child: Text(
                'Point camera at player\'s QR code',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}