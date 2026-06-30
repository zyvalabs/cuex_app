import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../common/widgets/appbar/appbar.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';

class AboutCueXScreen extends StatelessWidget {
  const AboutCueXScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final isTablet = sw > 600;

    return Scaffold(
      backgroundColor: TColors.peppercorn,
      appBar: TAppBar(
        showBackArrow: true,
        showActions: false,
        showSkipButton: false,
        title: Text('About CueX',
            style: Theme.of(context).textTheme.headlineMedium),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isTablet ? 24 : TSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Hero
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF141414),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.06)),
              ),
              child: Column(
                children: [
                  Text(
                    'CUE X',
                    style: GoogleFonts.bebasNeue(
                      fontSize: 48,
                      color: Colors.white,
                      letterSpacing: 10,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'LIVE SNOOKER & BILLIARDS',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade600,
                      letterSpacing: 4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(
                          color: Colors.red.withOpacity(0.2)),
                    ),
                    child: const Text(
                      'Building the Future of Cue Sports',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "We're just getting started on our journey to revolutionize cue sports",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwItems),

            // Mission
            _InfoCard(
              icon: Iconsax.tag_right,
              iconColor: Colors.red,
              title: 'Our Mission',
              body:
              'To revolutionize the cue sports industry by providing a comprehensive platform that connects players, venues, and enthusiasts. We make snooker and billiards more accessible, organized, and enjoyable for everyone — from beginners to professionals.',
            ),
            const SizedBox(height: TSizes.spaceBtwItems),

            // Vision
            _InfoCard(
              icon: Iconsax.eye,
              iconColor: const Color(0xFFD4A843),
              title: 'Our Vision',
              body:
              'To become the world\'s leading platform for cue sports, recognized for innovation, reliability, and community engagement. We envision instant access to top venues, live streaming, and opportunities to compete at all levels globally.',
            ),
            const SizedBox(height: TSizes.spaceBtwItems),

            // Core values
            _SectionHeading(title: 'Our Core Values'),
            const SizedBox(height: TSizes.spaceBtwItems),
            GridView.count(
              crossAxisCount: isTablet ? 4 : 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.2,
              children: const [
                _ValueCard(
                  emoji: '🏆',
                  title: 'Excellence',
                  subtitle: 'Highest quality platform',
                ),
                _ValueCard(
                  emoji: '💡',
                  title: 'Innovation',
                  subtitle: 'Cutting-edge technology',
                ),
                _ValueCard(
                  emoji: '🤝',
                  title: 'Community',
                  subtitle: 'Stronger cue sports family',
                ),
                _ValueCard(
                  emoji: '🎱',
                  title: 'Passion',
                  subtitle: 'Love for the sport',
                ),
              ],
            ),
            const SizedBox(height: TSizes.spaceBtwItems),

            // Story
            _InfoCard(
              icon: Iconsax.book,
              iconColor: Colors.blue,
              title: 'Our Story',
              body:
              'Founded by passionate cue sports enthusiasts, CueX was born from a simple observation: the cue sports community needed a modern, unified platform to connect players with venues and opportunities.\n\nWe\'re building a comprehensive ecosystem that will serve players and venues with features ranging from smart venue discovery to live match streaming, tournament management, and seamless table bookings.\n\nWe\'re just getting started on this exciting journey. CueX represents what technology and passion can achieve together, and we\'re thrilled to have you join us as we revolutionize cue sports.',
            ),
            const SizedBox(height: TSizes.spaceBtwItems),

            // What we bring
            _SectionHeading(title: 'What We Bring'),
            const SizedBox(height: TSizes.spaceBtwItems),

            _FeatureCard(
              icon: Iconsax.mobile,
              iconColor: Colors.red,
              title: 'Modern Technology',
              body:
              'Bringing cutting-edge digital solutions to venues — from smart booking systems to professional live streaming setups. We help transform traditional venues into modern, tech-enabled sports destinations.',
            ),
            const SizedBox(height: 8),
            _FeatureCard(
              icon: Iconsax.people,
              iconColor: const Color(0xFFD4A843),
              title: 'Community & Growth',
              body:
              'Creating connections between players and venues while fostering a vibrant cue sports community. We\'re committed to growing the sport through innovative features and meaningful engagement.',
            ),
            const SizedBox(height: TSizes.spaceBtwSections),

            // Footer
            Center(
              child: Column(
                children: [
                  Text(
                    '🎱',
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Play Like A Pro',
                    style: GoogleFonts.bebasNeue(
                      fontSize: 22,
                      color: Colors.white.withOpacity(0.3),
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '© 2026 ZyvaLabs. All rights reserved.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwSections),
          ],
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            body,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade500,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _ValueCard extends StatelessWidget {
  const _ValueCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
  });

  final String emoji;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}