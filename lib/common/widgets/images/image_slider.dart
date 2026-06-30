import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../../common/widgets/appbar/appbar.dart';
import '../../../../../common/widgets/custom_shapes/curved_edges/curved_edges_widget.dart';
import '../../../../../common/widgets/shimmers/shimmer.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/helpers/helper_functions.dart';
import '../../../features/shop/controllers/product/images_controller.dart';

class TImageSlider extends StatelessWidget {
  const TImageSlider({
    super.key,
    required this.images,
    this.isNetworkImage = true,
  });

  final List<String> images;
  final bool isNetworkImage;

  @override
  Widget build(BuildContext context) {
    final controller = ImagesController.instance;
    final isDark = THelperFunctions.isDarkMode(context);

    return TCurvedEdgesWidget(
      child: Container(
        color: isDark ? TColors.darkerGrey : TColors.light,
        child: Stack(
          children: [
            // ── Main Image ──────────────────────
            SizedBox(
              height: 400,
              width: double.infinity,
              child: GestureDetector(
                onTap: () => showDialog(
                  context: context,
                  builder: (_) => Dialog(
                    child: CachedNetworkImage(imageUrl: images.first),
                  ),
                ),
                child: isNetworkImage
                    ? CachedNetworkImage(
                  imageUrl: images.first,
                  fit: BoxFit.fitWidth,
                  width: double.infinity,
                  // ✅ shimmer while loading
                  placeholder: (_, __) => const TShimmerEffect(
                    width: double.infinity,
                    height: 400,
                    radius: 0,
                  ),
                  errorWidget: (_, __, ___) => Container(
                    height: 400,
                    color: const Color(0xFF1A1A1A),
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.white24,
                        size: 48,
                      ),
                    ),
                  ),
                )
                    : Image(
                  image: AssetImage(images.first),
                  fit: BoxFit.fitWidth,
                  width: double.infinity,
                ),
              ),
            ),

            // ── Appbar ──────────────────────────
            TAppBar(
              showBackArrow: true,
              showActions: false,
              showSkipButton: false,
            ),
          ],
        ),
      ),
    );
  }
}