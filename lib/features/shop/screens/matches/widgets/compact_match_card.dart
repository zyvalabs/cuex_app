import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../routes/routes.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/helpers/match_card_helper.dart';
import '../../../models/match_model.dart';

class CompactMatchCard extends StatefulWidget {
  const CompactMatchCard({super.key, required this.match});
  final MatchModel match;

  @override
  State<CompactMatchCard> createState() => _CompactMatchCardState();
}

class _CompactMatchCardState extends State<CompactMatchCard> {
  // ✅ cached — no rebuild on scroll
  late final Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = MatchDataHelper.getMatchData(widget.match);
  }

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
        final p1Init = data?['player1Initials'] ?? 'P';
        final p2Init = data?['player2Initials'] ?? 'P';
        final eventName = data?['eventName'] ?? '';
        final statusColor = MatchDataHelper.getStatusColor(widget.match.matchStatus);
        final isLive = widget.match.matchStatus.toLowerCase() == 'live';
        final isCompleted = widget.match.matchStatus.toLowerCase() == 'completed';

        return GestureDetector(
          onTap: () => Get.toNamed(TRoutes.matchDetails, arguments: widget.match),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: TColors.peppercorn,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Header ──────────────────
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.white10),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Status dot
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        MatchDataHelper.getStatus(widget.match.matchStatus),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const Spacer(),
                      if (eventName.isNotEmpty)
                        Text(
                          eventName,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white38,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),

                // ── Players + score ──────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      // Player 1
                      Expanded(
                        child: _PlayerCell(
                          name: p1Name,
                          imageUrl: p1Image,
                          initials: p1Init,
                          isWinner: widget.match.winnerId == widget.match.player1Id,
                          align: CrossAxisAlignment.start,
                        ),
                      ),

                      // Score
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isCompleted || isLive
                              ? '${widget.match.player1FramesWon} - ${widget.match.player2FramesWon}'
                              : 'vs',
                          style: GoogleFonts.bebasNeue(
                            fontSize: 18,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                      ),

                      // Player 2
                      Expanded(
                        child: _PlayerCell(
                          name: p2Name,
                          imageUrl: p2Image,
                          initials: p2Init,
                          isWinner: widget.match.winnerId == widget.match.player2Id,
                          align: CrossAxisAlignment.end,
                        ),
                      ),
                    ],
                  ),
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
// Player Cell
// ─────────────────────────────────────────────

class _PlayerCell extends StatelessWidget {
  const _PlayerCell({
    required this.name,
    required this.imageUrl,
    required this.initials,
    required this.isWinner,
    required this.align,
  });

  final String name;
  final String imageUrl;
  final String initials;
  final bool isWinner;
  final CrossAxisAlignment align;

  bool get _isLeft => align == CrossAxisAlignment.start;

  @override
  Widget build(BuildContext context) {
    final avatar = _buildAvatar();
    final nameWidget = Flexible(
      child: Text(
        name,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isWinner ? FontWeight.w700 : FontWeight.w500,
          color: isWinner ? Colors.white : Colors.white70,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: _isLeft ? TextAlign.left : TextAlign.right,
      ),
    );

    return Column(
      crossAxisAlignment: align,
      children: [
        Row(
          mainAxisAlignment:
          _isLeft ? MainAxisAlignment.start : MainAxisAlignment.end,
          children: _isLeft
              ? [avatar, const SizedBox(width: 8), nameWidget]
              : [nameWidget, const SizedBox(width: 8), avatar],
        ),
        if (isWinner) ...[
          const SizedBox(height: 3),
          Row(
            mainAxisAlignment:
            _isLeft ? MainAxisAlignment.start : MainAxisAlignment.end,
            children: [
              Icon(
                Icons.emoji_events_rounded,
                size: 10,
                color: const Color(0xFFD4A843),
              ),
              const SizedBox(width: 3),
              const Text(
                'Winner',
                style: TextStyle(
                  fontSize: 9,
                  color: Color(0xFFD4A843),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildAvatar() {
    final isValid = imageUrl.isNotEmpty && imageUrl.startsWith('http');
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isWinner
              ? const Color(0xFFD4A843)
              : Colors.white.withOpacity(0.08),
          width: isWinner ? 1.5 : 0.5,
        ),
        color: const Color(0xFF1E1E1E),
      ),
      child: ClipOval(
        child: isValid
            ? CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          errorWidget: (_, __, ___) => _initials(),
        )
            : _initials(),
      ),
    );
  }

  Widget _initials() => Center(
    child: Text(
      initials,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Colors.white54,
      ),
    ),
  );
}