import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class HighestBreakCard extends StatelessWidget {
  const HighestBreakCard({
    super.key,
    required this.rank,
    required this.playerName,
    required this.playerImage,
    required this.breakScore,
    this.subtitle,
  });

  final String rank;
  final String playerName;
  final String playerImage;
  final String breakScore;
  final String? subtitle;

  Color _accentColor(int r) {
    switch (r) {
      case 1: return const Color(0xFFD4A843);
      case 2: return Colors.white.withOpacity(0.5);
      case 3: return const Color(0xFFCD7F32);
      default: return Colors.white.withOpacity(0.08);
    }
  }

  Color _rankNumColor(int r) {
    switch (r) {
      case 1: return const Color(0xFFD4A843);
      case 2: return Colors.white60;
      case 3: return const Color(0xFFCD7F32);
      default: return Colors.white24;
    }
  }

  Color _scoreColor(int r) {
    switch (r) {
      case 1: return const Color(0xFFD4A843);
      case 2: return Colors.white70;
      case 3: return const Color(0xFFCD7F32);
      default: return Colors.white38;
    }
  }

  String _medal(int r) {
    switch (r) {
      case 1: return '🥇';
      case 2: return '🥈';
      case 3: return '🥉';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final isTablet = sw > 600;
    final rankInt = int.tryParse(rank) ?? 99;
    final isTop3 = rankInt <= 3;
    final isFirst = rankInt == 1;
    final isValidUrl = playerImage.isNotEmpty && playerImage.startsWith('http');
    final avatarSize = isFirst
        ? (isTablet ? 56.0 : 48.0)
        : (isTablet ? 48.0 : 40.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isFirst
            ? const Color(0xFF161616)
            : const Color(0xFF111111),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isTop3
              ? _accentColor(rankInt).withOpacity(0.25)
              : Colors.white.withOpacity(0.05),
        ),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          // top neon line
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isTop3
                      ? [Colors.transparent, _accentColor(rankInt), Colors.transparent]
                      : [Colors.transparent, Colors.white.withOpacity(0.08), Colors.transparent],
                ),
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 16 : 12,
              vertical: isTablet ? 14 : 12,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                // rank number
                SizedBox(
                  width: isTablet ? 36 : 30,
                  child: Text(
                    rankInt < 10 ? '0$rankInt' : '$rankInt',
                    style: GoogleFonts.bebasNeue(
                      fontSize: isFirst
                          ? (isTablet ? 28 : 24)
                          : (isTablet ? 22 : 18),
                      color: _rankNumColor(rankInt),
                      letterSpacing: 1,
                      height: 1,
                    ),
                  ),
                ),

                SizedBox(width: isTablet ? 12 : 10),

                // avatar
                Container(
                  width: avatarSize,
                  height: avatarSize,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isTop3
                          ? _accentColor(rankInt).withOpacity(0.6)
                          : Colors.white.withOpacity(0.08),
                      width: isFirst ? 2 : 1,
                    ),
                    boxShadow: isTop3
                        ? [BoxShadow(
                      color: _accentColor(rankInt).withOpacity(0.15),
                      blurRadius: 10,
                    )]
                        : null,
                  ),
                  child: ClipOval(
                    child: isValidUrl
                        ? Image.network(
                      playerImage,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _initials(rankInt, avatarSize),
                    )
                        : _initials(rankInt, avatarSize),
                  ),
                ),

                SizedBox(width: isTablet ? 14 : 12),

                // name + subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        playerName,
                        style: TextStyle(
                          fontSize: isFirst
                              ? (isTablet ? 16 : 14)
                              : (isTablet ? 14 : 13),
                          fontWeight: FontWeight.w800,
                          color: isTop3
                              ? Colors.white.withOpacity(isFirst ? 1.0 : 0.8)
                              : Colors.white.withOpacity(0.4),
                          letterSpacing: 0.2,
                          height: 1.1,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subtitle != null && subtitle!.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize: isTablet ? 10 : 9,
                            color: Colors.white.withOpacity(isTop3 ? 0.35 : 0.18),
                            letterSpacing: 0.3,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),

                SizedBox(width: isTablet ? 12 : 8),

                // break score + medal
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isTop3)
                      Text(
                        _medal(rankInt),
                        style: TextStyle(
                          fontSize: isFirst
                              ? (isTablet ? 26 : 22)
                              : (isTablet ? 22 : 18),
                        ),
                      ),
                    if (isTop3) const SizedBox(height: 2),
                    Text(
                      breakScore,
                      style: GoogleFonts.bebasNeue(
                        fontSize: isFirst
                            ? (isTablet ? 36 : 30)
                            : (isTablet ? 28 : 24),
                        color: _scoreColor(rankInt),
                        letterSpacing: 1,
                        height: 1,
                      ),
                    ),
                    Text(
                      'BREAK',
                      style: TextStyle(
                        fontSize: isTablet ? 9 : 8,
                        color: Colors.white.withOpacity(isTop3 ? 0.25 : 0.15),
                        letterSpacing: 2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _initials(int rankInt, double size) {
    final isTop3 = rankInt <= 3;
    return Center(
      child: Text(
        playerName.isNotEmpty ? playerName[0].toUpperCase() : '?',
        style: GoogleFonts.bebasNeue(
          fontSize: size * 0.42,
          color: isTop3 ? Colors.white : Colors.white,
        ),
      ),
    );
  }
}