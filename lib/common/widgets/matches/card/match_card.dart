import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../features/shop/controllers/match_stat_controller.dart';
import '../../../../features/shop/controllers/matches_controller.dart';
import '../../../../features/shop/models/match_model.dart';
import '../../../../features/shop/screens/matches/widgets/frame_display.dart';
import '../../../../features/shop/screens/matches/widgets/match_header.dart';
import '../../../../features/shop/screens/matches/widgets/match_status_widget.dart';
import '../../../../features/shop/screens/matches/widgets/match_time.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/helpers/match_card_helper.dart';
import '../../player/player_avatar.dart';
import '../../shimmers/match_shimmer.dart';

class MatchCard extends StatefulWidget {
  const MatchCard({
    super.key,
    required this.match,
    this.onTap,
    this.matchStatsController,
    this.showHeader = true,
    this.showBorder = true,
    this.animateOnOpen = false,
  });

  final MatchModel match;
  final VoidCallback? onTap;
  final MatchStatsController? matchStatsController;
  final bool showHeader;
  final bool showBorder;
  final bool animateOnOpen;

  @override
  State<MatchCard> createState() => _MatchCardState();
}

class _MatchCardState extends State<MatchCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _playerSpreadAnimation;
  late Animation<double> _centerFadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _playerSpreadAnimation = Tween<double>(begin: 0.01, end: 1.0).animate(
      CurvedAnimation(
          parent: _animationController, curve: Curves.easeOutCubic),
    );
    _centerFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );
    widget.animateOnOpen
        ? _animationController.forward()
        : _animationController.value = 1.0;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final isTablet = sw > 600;
    final isDesktop = sw > 900;

    final avatarSize = isDesktop ? 76.0 : isTablet ? 66.0 : 54.0;
    final centerWidth = isDesktop ? 150.0 : isTablet ? 130.0 : 105.0;
    final padH = isDesktop ? 24.0 : isTablet ? 20.0 : 14.0;
    final padV = isDesktop ? 18.0 : isTablet ? 14.0 : 10.0;
    final radius = isTablet ? 20.0 : 16.0;

    MatchStatsController? statsController = widget.matchStatsController;
    if (statsController == null) {
      try {
        statsController = Get.find<MatchStatsController>();
      } catch (_) {}
    }

    MatchController? matchController;
    try {
      if (Get.isRegistered<MatchController>()) {
        matchController = Get.find<MatchController>();
      }
    } catch (_) {}

    return FutureBuilder<Map<String, dynamic>>(
      future: MatchDataHelper.getMatchData(widget.match),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 5),
            child: TMatchCardShimmer(),
          );
        }
        final data = snapshot.data!;

        if (matchController == null) {
          final status = widget.match.matchStatus.toLowerCase();
          return _buildCard(
            data, widget.match, status, false,
            statsController, avatarSize, centerWidth, padH, padV, radius,
          );
        }

        return Obx(() {
          try {
            final liveMatch = matchController?.currentMatch.value;
            final displayMatch =
            (liveMatch?.id == widget.match.id) ? liveMatch! : widget.match;
            final status = displayMatch.matchStatus.toLowerCase();
            final isCurrentMatch =
                matchController?.currentMatch.value?.id == widget.match.id;
            return _buildCard(
              data, displayMatch, status, isCurrentMatch,
              statsController, avatarSize, centerWidth, padH, padV, radius,
            );
          } catch (_) {
            return _buildCard(
              data, widget.match, widget.match.matchStatus.toLowerCase(),
              false, statsController, avatarSize, centerWidth, padH, padV, radius,
            );
          }
        });
      },
    );
  }

  Widget _buildCard(
      Map<String, dynamic> data,
      MatchModel displayMatch,
      String status,
      bool isCurrentMatch,
      MatchStatsController? statsController,
      double avatarSize,
      double centerWidth,
      double padH,
      double padV,
      double radius,
      ) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: TColors.peppercorn,
          borderRadius: BorderRadius.circular(radius),
          border: widget.showBorder
              ? Border.all(color: Colors.white10)
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.showHeader)
              MatchHeader(
                eventName: data['eventName'] ?? '',
                roundName: data['roundName'] ?? '',
                status: MatchDataHelper.getStatus(displayMatch.matchStatus),
                statusColor:
                MatchDataHelper.getStatusColor(displayMatch.matchStatus),
              ),
            if (widget.showHeader)
              const Divider(color: Colors.white10, height: 1),
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, _) {
                return Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: padH, vertical: padV),
                  child: statsController != null
                      ? Obx(() {
                    try {
                      final isCurrent =
                      Get.isRegistered<MatchController>()
                          ? Get.find<MatchController>()
                          .currentMatch
                          .value
                          ?.id ==
                          widget.match.id
                          : false;
                      return _buildRow(
                        data, displayMatch, status, isCurrent,
                        statsController, avatarSize, centerWidth,
                      );
                    } catch (_) {
                      return _buildRow(
                        data, displayMatch, status, false,
                        statsController, avatarSize, centerWidth,
                      );
                    }
                  })
                      : _buildRow(
                    data, displayMatch, status, isCurrentMatch,
                    null, avatarSize, centerWidth,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(
      Map<String, dynamic> data,
      MatchModel displayMatch,
      String status,
      bool isCurrentMatch,
      MatchStatsController? controller,
      double avatarSize,
      double centerWidth,
      ) {
    return Row(
      children: [
        Expanded(
          child: PlayerAvatar(
            imagePath: data['player1Image'] ?? '',
            initials: data['player1Initials'] ?? 'P',
            playerName: data['player1Name'],
            points: displayMatch.player1CurrentPoints.toString(),
            size: avatarSize,
            isActive: isCurrentMatch &&
                controller?.getCurrentPlayer(widget.match.id) == 'player1',
            isWinner: widget.match.winnerId == widget.match.player1Id,
          ),
        ),
        SizedBox(
          width: centerWidth * _playerSpreadAnimation.value,
          child: Opacity(
            opacity: _centerFadeAnimation.value,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                MatchStatusBadge(status: widget.match.matchStatus),
                const SizedBox(height: 8),
                status == 'upcoming'
                    ? MatchTime(scheduledTime: widget.match.scheduledTime)
                    : FramesDisplay(
                  leftScore:
                  displayMatch.player1FramesWon.toString(),
                  totalFrames: displayMatch.totalFrames.toString(),
                  rightScore:
                  displayMatch.player2FramesWon.toString(),
                  label: data['roundName'] ?? 'FRAMES',
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: PlayerAvatar(
            imagePath: data['player2Image'] ?? '',
            initials: data['player2Initials'] ?? 'P',
            playerName: data['player2Name'],
            points: displayMatch.player2CurrentPoints.toString(),
            size: avatarSize,
            isActive: isCurrentMatch &&
                controller?.getCurrentPlayer(widget.match.id) == 'player2',
            isWinner: widget.match.winnerId == widget.match.player2Id,
          ),
        ),
      ],
    );
  }
}