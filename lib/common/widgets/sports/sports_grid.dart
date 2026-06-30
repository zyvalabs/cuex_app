import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../features/shop/models/sport_model.dart';class SportsGrid extends StatelessWidget {
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
          final isValidUrl = sport.iconUrl.isNotEmpty && sport.iconUrl.startsWith('http');
          final cardWidth = (MediaQuery.of(context).size.width - 48) / 3;

          return GestureDetector(
            onTap: () => onTap?.call(sport),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 10),
              width: cardWidth,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFC8A84B).withOpacity(0.12)
                    : const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFC8A84B)
                      : const Color(0xFF2C2C2C),
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
                        placeholder: (_, __) => const Icon(
                          Icons.sports,
                          size: 40,
                          color: Colors.white12,
                        ),
                        errorWidget: (_, __, ___) => const Icon(
                          Icons.sports,
                          size: 40,
                          color: Colors.white38,
                        ),
                      )
                          : const Icon(
                        Icons.sports,
                        size: 40,
                        color: Colors.white38,
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
                            ? const Color(0xFFC8A84B).withOpacity(0.18)
                            : const Color(0xFF222222),
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
                          color: isSelected
                              ? const Color(0xFFC8A84B)
                              : Colors.white70,
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