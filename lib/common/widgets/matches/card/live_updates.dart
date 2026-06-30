import 'package:flutter/material.dart';

import '../../../../utils/constants/colors.dart';
import '../../custom_shapes/containers/flexible_container.dart';
class LiveUpdatesCard extends StatelessWidget {
  const LiveUpdatesCard({
    super.key,
    required this.title,
    required this.playerName,
    required this.playerImage,
    this.subtitle,
    this.value,
    this.valueColor = Colors.greenAccent,
    this.showConfetti = false,
  });

  final String title;
  final String playerName;
  final String playerImage;
  final String? subtitle;
  final String? value;
  final Color valueColor;
  final bool showConfetti;

  @override
  Widget build(BuildContext context) {
    return TFlexibleContainer(
      height: 250,
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      backgroundColor: TColors.peppercorn,
      borderColor: Colors.grey.shade800,
      borderWidth: 1,
      child: Column(
        children: [
          // Top - 60%
          Expanded(
            flex: 6,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.grey.shade900,
                    Colors.black,
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Left 60% - Title + Player Name
                    Expanded(
                      flex: 6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            title,
                            style: Theme.of(context).textTheme.titleMedium?.apply(color: Colors.grey.shade400),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            playerName,
                            style: Theme.of(context).textTheme.headlineMedium?.apply(
                              color: Colors.white,
                              fontWeightDelta: 2,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Right 40% - Player Avatar
                    Expanded(
                      flex: 4,
                      child: Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: playerImage.startsWith('http')
                              ? Image.network(
                            playerImage,
                            width: 80,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 80,
                              height: 100,
                              color: Colors.grey.shade800,
                              child: const Icon(Icons.person, size: 40, color: Colors.white54),
                            ),
                          )
                              : Image.asset(
                            playerImage,
                            width: 80,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 80,
                              height: 100,
                              color: Colors.grey.shade800,
                              child: const Icon(Icons.person, size: 40, color: Colors.white54),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Divider
          Divider(color: Colors.grey.shade700, thickness: 1, height: 1),

          // Bottom - 40%
          Expanded(
            flex: 4,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.grey.shade900,
                    Colors.grey.shade800,
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.bodyMedium?.apply(color: Colors.grey.shade400),
                      ),
                    if (subtitle != null) const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          playerName,
                          style: Theme.of(context).textTheme.titleLarge?.apply(
                            color: Colors.white,
                            fontWeightDelta: 2,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'wins',
                          style: Theme.of(context).textTheme.bodyLarge?.apply(color: Colors.grey.shade300),
                        ),
                      ],
                    ),
                    if (value != null) const SizedBox(height: 4),
                    if (value != null)
                      Text(
                        value!,
                        style: Theme.of(context).textTheme.headlineSmall?.apply(
                          color: valueColor,
                          fontWeightDelta: 2,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}