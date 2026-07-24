import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../features/shop/models/sport_model.dart';

class SportsGrid extends StatelessWidget {
  const SportsGrid({
    super.key,
    required this.sports,
    this.selectedSportIds = const [],
    this.onTap,
    this.multiSelect = false,
  });

  final List<SportModel> sports;
  final List<String> selectedSportIds;
  final Function(SportModel)? onTap;
  final bool multiSelect;

  static const Color _accent = Color(0xFF0F6E56);
  static const Color _accentBg = Color(0xFFE1F5EE);
  static const Color _border = Color(0xFFE5E5E5);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: sports.length,
        itemBuilder: (_, index) {
          final sport = sports[index];
          final isSelected = selectedSportIds.contains(sport.id);
          final isValidUrl =
              sport.iconUrl.isNotEmpty && sport.iconUrl.startsWith('http');
          final cardWidth = (MediaQuery.of(context).size.width - 48) / 3;

          return GestureDetector(
            onTap: () => onTap?.call(sport),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 10),
              width: cardWidth,
              decoration: BoxDecoration(
                color: isSelected ? _accentBg : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? _accent : _border,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Column(
                children: [
                  // 70% — icon
                  Expanded(
                    flex: 7,
                    child: Center(
                      child: isValidUrl
                          ? CachedNetworkImage(
                        imageUrl: sport.iconUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.contain,
                        placeholder: (_, __) => Icon(
                          Icons.sports,
                          size: 40,
                          color: Colors.grey.shade300,
                        ),
                        errorWidget: (_, __, ___) => Icon(
                          Icons.sports,
                          size: 40,
                          color: Colors.grey.shade400,
                        ),
                      )
                          : Icon(
                        Icons.sports,
                        size: 40,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ),

                  // 30% — name strip
                  Expanded(
                    flex: 3,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _accent.withOpacity(0.12)
                            : const Color(0xFFF5F5F5),
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(16),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        sport.name,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? _accent : Colors.black54,
                          letterSpacing: 0.3,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}