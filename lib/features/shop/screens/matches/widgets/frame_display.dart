import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FramesDisplay extends StatelessWidget {
  const FramesDisplay({
    super.key,
    required this.leftScore,
    required this.totalFrames,
    required this.rightScore,
    this.label = 'FRAMES',
  });

  final String leftScore;
  final String totalFrames;
  final String rightScore;
  final String label;

  String get _capitalizedLabel => label
      .split(' ')
      .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final isTablet = sw > 600;
    final isDesktop = sw > 900;
    final scoreSize = isDesktop ? 40.0 : isTablet ? 36.0 : 28.0;
    final totalSize = isDesktop ? 24.0 : isTablet ? 22.0 : 17.0;
    final labelSize = isDesktop ? 14.0 : isTablet ? 13.0 : 11.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _capitalizedLabel,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.bebasNeue(
              fontSize: labelSize,
              letterSpacing: 1.5,
              color: Colors.white54,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                leftScore,
                style: GoogleFonts.bebasNeue(
                  fontSize: scoreSize,
                  color: Colors.white,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  '($totalFrames)',
                  style: GoogleFonts.bebasNeue(
                    fontSize: totalSize,
                    color: Colors.white38,
                  ),
                ),
              ),
              Text(
                rightScore,
                style: GoogleFonts.bebasNeue(
                  fontSize: scoreSize,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}