import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/enums.dart';
import '../../../../../utils/constants/sizes.dart';

import '../../../../common/widgets/tab bar/cuex_tab_bar.dart';
import '../../../personalization/controllers/user_controller.dart';
import '../../controllers/event_draw_controller.dart';
import '../../models/event_draw_model.dart';
import 'widgets/add_draw_bottom_sheet.dart';
import 'widgets/draw_card.dart';


class EventDrawScreen extends StatefulWidget {
  const EventDrawScreen({super.key, required this.eventId});
  final String eventId;

  @override
  State<EventDrawScreen> createState() => _EventDrawScreenState();
}

class _EventDrawScreenState extends State<EventDrawScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final EventDrawController controller;

  AppRole get _role => UserController.instance.user.value.role;
  bool get _isAdminOrPartner =>
      _role == AppRole.admin || _role == AppRole.partner;
  String get _currentType =>
      _tabController.index == 0 ? 'draw' : 'result';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    controller = Get.isRegistered<EventDrawController>()
        ? Get.find<EventDrawController>()
        : Get.put(EventDrawController());

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
        _refresh(_currentType);
      }
    });

    // Fetch both tabs on init
    _refresh('draw');
    _refresh('result');
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refresh(String type) async {
    await controller.fetchDraws(widget.eventId, type);
  }

  void _confirmDelete(EventDrawModel draw) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete'),
        content: Text('Delete "${draw.title}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              controller.deleteDraw(draw, widget.eventId);
            },
            child: const Text('Delete',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _openFullScreen(EventDrawModel draw) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _FullScreenImageView(draw: draw),
      ),
    );
  }

  Widget _buildList(String type) {
    return Obx(() {
      final items = type == 'draw'
          ? controller.draws.toList()
          : controller.results.toList();

      if (controller.isLoading.value) {
        return _DrawShimmer();
      }

      if (items.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                type == 'draw' ? Iconsax.document : Iconsax.chart,
                size: 48,
                color: Colors.grey.shade700,
              ),
              const SizedBox(height: 12),
              Text(
                type == 'draw'
                    ? 'No draw uploaded yet'
                    : 'No results uploaded yet',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => _refresh(type),
        color: TColors.primary,
        backgroundColor: const Color(0xFF1C1C1C),
        child: ListView.separated(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          itemCount: items.length,
          separatorBuilder: (_, __) =>
          const SizedBox(height: TSizes.spaceBtwItems),
          itemBuilder: (_, i) {
            final draw = items[i];
            return DrawCard(
              draw: draw,
              isAdminOrPartner: _isAdminOrPartner,
              onTap: () => _openFullScreen(draw),
              onEdit: _isAdminOrPartner
                  ? () async {
                await AddDrawBottomSheet.show(
                  context,
                  eventId: widget.eventId,
                  type: type,
                  existingDraw: draw,
                );
                _refresh(type);
              }
                  : null,
              onDelete: _isAdminOrPartner
                  ? () => _confirmDelete(draw)
                  : null,
            );
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        // Tab bar
        CueXTabBar(
          controller: _tabController,
          tabs: const ['Draw', 'Results'],
        ),

        // Upload button — admin/partner only
        if (_isAdminOrPartner)
          Padding(
            padding: const EdgeInsets.fromLTRB(
                TSizes.defaultSpace, 10, TSizes.defaultSpace, 0),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await AddDrawBottomSheet.show(
                    context,
                    eventId: widget.eventId,
                    type: _currentType,
                  );
                  await _refresh(_currentType);
                  setState(() {});
                },
                icon: const Icon(Iconsax.document_upload
                    , size: 16),
                label: Text(_currentType == 'draw'
                    ? 'Upload Draw'
                    : 'Upload Result'),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                      color: TColors.primary.withOpacity(0.4)),
                  foregroundColor: TColors.primary,
                ),
              ),
            ),
          ),

        // Lists
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildList('draw'),
              _buildList('result'),
            ],
          ),
        ),
      ],
    );
  }
}

/// Shimmer loading for draw cards
class _DrawShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(TSizes.defaultSpace),
      itemCount: 2,
      separatorBuilder: (_, __) =>
      const SizedBox(height: TSizes.spaceBtwItems),
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: const Color(0xFF1C1C1C),
        highlightColor: const Color(0xFF2A2A2A),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1C),
            borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image placeholder
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(TSizes.cardRadiusLg)),
                ),
              ),
              // Footer placeholder
              Padding(
                padding: const EdgeInsets.all(TSizes.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 14,
                      width: 160,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 10,
                      width: 100,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Full screen pinch-to-zoom image viewer
class _FullScreenImageView extends StatelessWidget {
  const _FullScreenImageView({required this.draw});
  final EventDrawModel draw;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(draw.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: InteractiveViewer(
        minScale: 0.5,
        maxScale: 4.0,
        child: Center(
          child: draw.imageUrl.isNotEmpty
              ? Image.network(
            draw.imageUrl,
            fit: BoxFit.contain,
            loadingBuilder: (_, child, progress) {
              if (progress == null) return child;
              return Shimmer.fromColors(
                baseColor: const Color(0xFF1C1C1C),
                highlightColor: const Color(0xFF2A2A2A),
                child: Container(
                  height: 300,
                  width: double.infinity,
                  color: const Color(0xFF1C1C1C),
                ),
              );
            },
            errorBuilder: (_, __, ___) => const Icon(
              Iconsax.image,
              size: 48,
              color: Colors.grey,
            ),
          )
              : const Icon(Iconsax.image, size: 48, color: Colors.grey),
        ),
      ),
    );
  }
}