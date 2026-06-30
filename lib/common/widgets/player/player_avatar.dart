import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PlayerAvatar extends StatelessWidget {
  const PlayerAvatar({
    super.key,
    required this.imagePath,
    this.initials,
    this.playerName,
    this.points,
    this.showName = true,
    this.showPoints = true,
    this.isActive = false,
    this.isWinner = false,
    this.size = 54,
    this.namePosition = NamePosition.below,
  });

  final String imagePath;
  final String? initials;
  final String? playerName;
  final String? points;
  final bool showName;
  final bool showPoints;
  final bool isActive;
  final bool isWinner;
  final double size;
  final NamePosition namePosition;

  String get _firstName {
    if (playerName == null) return '';
    return playerName!.trim().split(' ').first;
  }

  String get _lastName {
    if (playerName == null) return '';
    final parts = playerName!.trim().split(' ');
    return parts.length > 1 ? parts.sublist(1).join(' ') : '';
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final isTablet = sw > 600;
    final isDesktop = sw > 900;

    final scaleFactor = isDesktop ? 1.2 : isTablet ? 1.1 : 1.0;
    final h = size * scaleFactor;
    final w = h * (7 / 8);
    final isValidUrl = imagePath.isNotEmpty && imagePath.startsWith('http');
    final displayInitials = initials ?? playerName?[0].toUpperCase() ?? '?';

    Color borderColor = Colors.white24;
    double borderWidth = 0.5;
    List<BoxShadow>? shadows;

    if (isWinner) {
      borderColor = const Color(0xFFD4A843); // ← softer gold
      borderWidth = 1.5;
      shadows = [BoxShadow(color: const Color(0xFFD4A843).withOpacity(0.15), blurRadius: 8)]; // ← less glow
    }
    if (isActive) {
      borderColor = Colors.green;
      borderWidth = 2;
      shadows = [BoxShadow(color: Colors.green.withOpacity(0.35), blurRadius: 10)];
    }

    final avatarWidget = Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: h,
          width: w,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(isTablet ? 14 : 10),
            border: Border.all(color: borderColor, width: borderWidth),
            boxShadow: shadows,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
            child: isValidUrl
                ? Image.network(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Center(
                child: Text(
                  displayInitials,
                  style: GoogleFonts.bebasNeue(
                    color: Colors.white,
                    fontSize: h * 0.45,
                  ),
                ),
              ),
            )
                : Center(
              child: Text(
                displayInitials,
                style: GoogleFonts.bebasNeue(
                  color: Colors.white,
                  fontSize: h * 0.45,
                ),
              ),
            ),
          ),
        ),
        if (isWinner)
          Positioned(
            top: -8,
            right: -15,
            child: Icon(
              Icons.emoji_events_rounded,
              color: const Color(0xFFFFBF00),
              size: isTablet ? 20 : 16,
            ),
          ),
      ],
    );

    Widget? nameWidget;
    if (showName && playerName != null) {
      final firstSize = h * 0.22;
      final lastSize = h * 0.15;
      nameWidget = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _firstName.toUpperCase(),
            style: GoogleFonts.bebasNeue(
              color: Colors.white,
              fontSize: firstSize,
              letterSpacing: 1.5,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          if (_lastName.isNotEmpty)
            Text(
              _lastName.toUpperCase(),
              style: GoogleFonts.bebasNeue(
                color: Colors.white60,
                fontSize: lastSize,
                letterSpacing: 1,
              ),
              overflow: TextOverflow.ellipsis,
            ),
        ],
      );
    }

    Widget? pointsWidget;
    if (showPoints && points != null) {
      pointsWidget = Text(
        points!,
        style: GoogleFonts.bebasNeue(
          color: isActive ? Colors.green : Colors.white,
          fontSize: h * 0.38, // ← bigger
          letterSpacing: 1,
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        avatarWidget,
        if (nameWidget != null) ...[
          SizedBox(height: isTablet ? 10 : 8),
          nameWidget,
        ],
        if (pointsWidget != null) ...[
          SizedBox(height: isTablet ? 6 : 4),
          pointsWidget,
        ],
      ],
    );
  }
}

enum NamePosition { below, right, left }