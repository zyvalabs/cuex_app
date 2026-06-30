// ─────────────────────────────────────────────
// top_breaks_podium.dart
// ─────────────────────────────────────────────

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../common/widgets/shimmers/shimmer.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../controllers/high_break.dart';
import '../leaderboard_screen.dart';

class TopBreaksPodium extends StatelessWidget {
  const TopBreaksPodium({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<HighestBreaksController>()
        ? Get.find<HighestBreaksController>()
        : Get.put(HighestBreaksController());

    return Obx(() {
      if (controller.isFetching.value && controller.topBreaks.isEmpty) {
        return const _BreaksShimmer();
      }

      final breaks = controller.topBreaks
          .where((b) => b.breakScore >= 70)
          .take(3)
          .toList();

      if (breaks.isEmpty && controller.topBreaks.isNotEmpty) {
        return const _SoftEmptyState();
      }

      if (breaks.isEmpty) {
        return const _EmptyState();
      }

      return Column(
        children: [
          ...breaks.asMap().entries.map((entry) =>
              BreakAccentCard(breakModel: entry.value, rank: entry.key + 1)),
          const SizedBox(height: TSizes.spaceBtwItems),
          const _ViewAllButton(),
        ],
      );
    });
  }
}

// ─────────────────────────────────────────────
// Shared Break Card — Option C minimal accent line
// Used in both TopBreaksPodium and LeaderboardScreen
// ─────────────────────────────────────────────
class BreakAccentCard extends StatelessWidget {
  const BreakAccentCard({
    super.key,
    required this.breakModel,
    required this.rank,
  });

  final HighestBreakModel breakModel;
  final int rank;

  Color get _accentColor {
    switch (rank) {
      case 1:
        return const Color(0xFFD4A843);
      case 2:
        return const Color(0xFF9AAABB);
      case 3:
        return const Color(0xFFCD7F32);
      default:
        return TColors.june;
    }
  }

  String get _medal {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isValidUrl = breakModel.playerImage.isNotEmpty &&
        breakModel.playerImage.startsWith('http');

    final isTop3 = rank <= 3;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: TColors.black,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Row(
          children: [

            // ACCENT LINE
            Container(
              width: 3,
              height: 78,
              color: _accentColor,
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Row(
                  children: [

                    // RANK
                    SizedBox(
                      width: 32,
                      child: Text(
                        rank < 10 ? '0$rank' : '$rank',
                        style: GoogleFonts.bebasNeue(
                          fontSize: isTop3 ? 22 : 18,
                          color:
                          isTop3 ? _accentColor : Colors.white24,
                          letterSpacing: 1,
                          height: 1,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(width: 10),

                    // AVATAR
                    Container(
                      width: isTop3 ? 42 : 36,
                      height: isTop3 ? 42 : 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isTop3
                              ? _accentColor.withOpacity(0.5)
                              : Colors.white.withOpacity(0.08),
                          width: isTop3 ? 1.5 : 0.5,
                        ),
                        color: const Color(0xFF1E1E1E),
                      ),
                      child: ClipOval(
                        child: isValidUrl
                            ? CachedNetworkImage(
                          imageUrl: breakModel.playerImage,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) =>
                              _initials(),
                        )
                            : _initials(),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // NAME + TYPE
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        mainAxisAlignment:
                        MainAxisAlignment.center,
                        children: [

                          Text(
                            breakModel.playerName,
                            style: TextStyle(
                              fontSize: isTop3 ? 14 : 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 3),

                          // Text(
                          //   breakModel.matchType == 'practice'
                          //       ? 'Practice'
                          //       : 'Tournament',
                          //   style: TextStyle(
                          //     fontSize: 10,
                          //     color:
                          //     Colors.white.withOpacity(0.3),
                          //   ),
                          // ),
                        ],
                      ),
                    ),

                    // SCORE
                    Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.end,
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      children: [

                        if (_medal.isNotEmpty)
                          Padding(
                            padding:
                            const EdgeInsets.only(bottom: 2),
                            child: Text(
                              _medal,
                              style:
                              const TextStyle(fontSize: 14),
                            ),
                          ),

                        Text(
                          breakModel.breakScore.toString(),
                          style: GoogleFonts.bebasNeue(
                            fontSize: isTop3 ? 30 : 22,
                            color: isTop3
                                ? _accentColor
                                : TColors.june,
                            letterSpacing: 1,
                            height: 1,
                          ),
                        ),

                        Text(
                          'BREAK',
                          style: TextStyle(
                            fontSize: 8,
                            color: isTop3
                                ? _accentColor.withOpacity(0.5)
                                : TColors.june.withOpacity(0.4),
                            letterSpacing: 2,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _initials() {
    return Center(
      child: Text(
        breakModel.playerName.isNotEmpty
            ? breakModel.playerName[0].toUpperCase()
            : '?',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: _accentColor,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Shimmer
// ─────────────────────────────────────────────

class _BreaksShimmer extends StatelessWidget {
  const _BreaksShimmer();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(3, (_) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        height: 68,
        decoration: BoxDecoration(
          color: const Color(0xFF141414),
          borderRadius: BorderRadius.circular(14),
          border: Border(
            left: BorderSide(
                color: Colors.white.withOpacity(0.06), width: 3),
            top: BorderSide(
                color: Colors.white.withOpacity(0.05), width: 0.5),
            right: BorderSide(
                color: Colors.white.withOpacity(0.05), width: 0.5),
            bottom: BorderSide(
                color: Colors.white.withOpacity(0.05), width: 0.5),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              TShimmerEffect(width: 28, height: 18, radius: 4),
              const SizedBox(width: 10),
              TShimmerEffect(width: 42, height: 42, radius: 21),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TShimmerEffect(width: 110, height: 13, radius: 4),
                    const SizedBox(height: 5),
                    TShimmerEffect(width: 70, height: 10, radius: 4),
                  ],
                ),
              ),
              TShimmerEffect(width: 36, height: 36, radius: 4),
            ],
          ),
        ),
      )),
    );
  }
}

// ─────────────────────────────────────────────
// View All Button
// ─────────────────────────────────────────────

class _ViewAllButton extends StatelessWidget {
  const _ViewAllButton();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => const LeaderboardScreen()),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
          border: Border.all(color: Colors.white.withOpacity(0.07)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'View All',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 6),
            Icon(Iconsax.arrow_right_3, size: 14, color: TColors.june),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Empty State
// ─────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: TColors.june.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Iconsax.cup, size: 26,
                color: TColors.june.withOpacity(0.5)),
          ),
          const SizedBox(height: 14),
          Text(
            'No Century Breaks Yet',
            style: GoogleFonts.bebasNeue(
              fontSize: 20,
              color: Colors.white70,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Be the first to make a break of 70+\nand claim the top spot.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white38,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Soft Empty
// ─────────────────────────────────────────────

class _SoftEmptyState extends StatelessWidget {
  const _SoftEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Icon(Iconsax.info_circle, size: 16,
              color: TColors.june.withOpacity(0.5)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'No breaks over 70 recorded yet. Keep playing!',
              style: TextStyle(
                  fontSize: 12, color: Colors.white38, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

