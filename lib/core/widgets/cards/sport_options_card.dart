import 'package:flutter/material.dart';

/// Fully customizable rectangular sport-option tile — image on top, name below.
/// Use in a grid/list for sport selection ("Snooker", "Pool", "Carrom", etc).
class SportOptionCard extends StatelessWidget {
  final String sportName;
  final String? imagePath;
  final bool isSelected;
  final VoidCallback? onTap;

  final Color containerColor;
  final Color borderColor;
  final double borderRadius;

  final Color textColor;
  final double textFontSize;
  final FontWeight textFontWeight;

  final Color imageBackgroundColor;
  final BoxFit imageFit;

  const SportOptionCard({
    super.key,
    required this.sportName,
    this.imagePath,
    this.isSelected = false,
    this.onTap,
    this.containerColor = Colors.white,
    this.borderColor = Colors.black,
    this.borderRadius = 12,
    this.textColor = Colors.black,
    this.textFontSize = 14,
    this.textFontWeight = FontWeight.w700,
    this.imageBackgroundColor = Colors.transparent,
    this.imageFit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: containerColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: 1.4, // rectangular box
              child: Container(
                decoration: BoxDecoration(
                  color: imageBackgroundColor,
                  borderRadius: BorderRadius.circular(borderRadius - 4),
                ),
                clipBehavior: Clip.antiAlias,
                child: imagePath != null
                    ? Image.asset(imagePath!, fit: imageFit)
                    : const Icon(Icons.image, color: Colors.white38),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              sportName,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
              style: TextStyle(
                color: textColor,
                fontSize: textFontSize,
                fontWeight: textFontWeight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}