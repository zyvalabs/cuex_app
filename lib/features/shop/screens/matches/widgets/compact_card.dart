import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../routes/routes.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/helpers/match_card_helper.dart';
import '../../../models/match_model.dart';

class CompactMatchCard extends StatefulWidget {
  const CompactMatchCard({
    super.key,
    required this.match,
    this.onTap,
  });

  final MatchModel match;
  final VoidCallback? onTap;

  @override
  State<CompactMatchCard> createState() => _CompactMatchCardState();
}

class _CompactMatchCardState extends State<CompactMatchCard> {
  late final Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = MatchDataHelper.getMatchData(widget.match);
  }

  bool get _isPractice => widget.match.matchType == 'practice';

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _future,
      builder: (context, snapshot) {
        final data = snapshot.data;
        final p1Name = data?['player1Name'] ?? widget.match.player1Name ?? 'Player 1';
        final p2Name = data?['player2Name'] ?? widget.match.player2Name ?? 'Player 2';
        final p1Image = data?['player1Image'] ?? '';
        final p2Image = data?['player2Image'] ?? '';
        final p1Init = data?['player1Initials'] ?? (p1Name.isNotEmpty ? p1Name[0].toUpperCase() : 'P');
        final p2Init = data?['player2Initials'] ?? (p2Name.isNotEmpty ? p2Name[0].toUpperCase() : 'P');
        final eventName = data?['eventName'] ?? '';

        final pillLabel = _isPractice
            ? 'PRACTICE'
            : eventName.isNotEmpty
            ? eventName.toUpperCase()
            : 'TOURNAMENT';

        return GestureDetector(
          onTap: widget.onTap ??
                  () => Get.toNamed(TRoutes.matchDetails, arguments: widget.match),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF141414),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: Row(
              children: [
                // ── Player 1 avatar ──────────
                _Avatar(
                  imageUrl: p1Image,
                  initials: p1Init,
                  isPlayer1: true,
                  isWinner: widget.match.winnerId == widget.match.player1Id,
                ),
                const SizedBox(width: 10),

                // ── Player 1 name ─────────────
                Expanded(
                  child: Text(
                    p1Name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                  ),
                ),

                // ── Center ────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: TColors.june.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(99),
                          border: Border.all(
                            color: TColors.june.withOpacity(0.2),
                          ),
                        ),
                        child: Text(
                          pillLabel,
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            color: TColors.june,
                            letterSpacing: 0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${widget.match.player1FramesWon} - ${widget.match.player2FramesWon}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'FRAMES',
                        style: TextStyle(
                          fontSize: 7,
                          letterSpacing: 1.5,
                          color: Colors.white.withOpacity(0.2),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Player 2 name ─────────────
                Expanded(
                  child: Text(
                    p2Name,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.6),
                    ),
                    textAlign: TextAlign.right,
                    maxLines: 2,
                  ),
                ),
                const SizedBox(width: 10),

                // ── Player 2 avatar ──────────
                _Avatar(
                  imageUrl: p2Image,
                  initials: p2Init,
                  isPlayer1: false,
                  isWinner: widget.match.winnerId == widget.match.player2Id,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// Avatar
// ─────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.imageUrl,
    required this.initials,
    required this.isPlayer1,
    required this.isWinner,
  });

  final String imageUrl;
  final String initials;
  final bool isPlayer1;
  final bool isWinner;

  @override
  Widget build(BuildContext context) {
    final isValid = imageUrl.isNotEmpty && imageUrl.startsWith('http');
    final borderColor = isWinner
        ? const Color(0xFFD4A843)
        : isPlayer1
        ? TColors.june.withOpacity(0.4)
        : Colors.white.withOpacity(0.1);
    final bgColor = isPlayer1
        ? TColors.june.withOpacity(0.1)
        : Colors.white.withOpacity(0.05);
    final textColor =
    isPlayer1 ? TColors.june : Colors.white.withOpacity(0.45);

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: isWinner ? 1.5 : 0.5,
        ),
        color: bgColor,
      ),
      child: ClipOval(
        child: isValid
            ? CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          errorWidget: (_, __, ___) => _initials(textColor),
        )
            : _initials(textColor),
      ),
    );
  }

  Widget _initials(Color color) => Center(
    child: Text(
      initials,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: color,
      ),
    ),
  );
}