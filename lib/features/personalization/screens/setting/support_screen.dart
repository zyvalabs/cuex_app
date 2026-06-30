import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../common/widgets/appbar/appbar.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  Future<void> _openWhatsApp() async {
    final uri = Uri.parse(
        'https://wa.me/919108906554?text=Hi%20CueX%20Support%2C%20I%20need%20help%20with%20');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.peppercorn,
      appBar: TAppBar(
        showBackArrow: true,
        showActions: false,
        showSkipButton: false,
        title: Text(
          'Help & Support',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),

      // ── Fixed bottom WhatsApp button ──────
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: GestureDetector(
            onTap: _openWhatsApp,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                color: TColors.june,
                borderRadius: BorderRadius.circular(14),

              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Chat on WhatsApp',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero card ───────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF141414),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.06)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: TColors.june.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.support_agent_rounded,
                      size: 26,
                      color: TColors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "We're here to help 👋",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Onboarding, streaming, technical issues or any queries — reach out anytime.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.4),
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Container(
                  //   padding: const EdgeInsets.symmetric(
                  //     horizontal: 12,
                  //     vertical: 5,
                  //   ),
                  //   decoration: BoxDecoration(
                  //     color: TColors.june.withOpacity(0.08),
                  //     borderRadius: BorderRadius.circular(99),
                  //     border: Border.all(
                  //       color: TColors.june.withOpacity(0.2),
                  //     ),
                  //   ),
                  //   child: Text(
                  //     '⚡ Available 24/7',
                  //     style: TextStyle(
                  //       color: TColors.june,
                  //       fontSize: 11,
                  //       fontWeight: FontWeight.w600,
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwItems),

            // ── What we help with ───────────
            Text(
              'WHAT WE HELP WITH',
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withOpacity(0.25),
                letterSpacing: 2,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF141414),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.06)),
              ),
              child: Column(
                children: [
                  _HelpTopic(
                    icon: Iconsax.user_add,
                    title: 'Onboarding',
                    subtitle: 'Setting up your venue or player account',
                  ),
                  _HelpTopic(
                    icon: Iconsax.video_play,
                    title: 'Live Streaming',
                    subtitle: 'YouTube setup, OBS, streaming issues',
                  ),
                  _HelpTopic(
                    icon: Iconsax.cup,
                    title: 'Tournaments & Events',
                    subtitle: 'Managing draws, results, registrations',
                  ),
                  _HelpTopic(
                    icon: Iconsax.mobile,
                    title: 'Technical Issues',
                    subtitle: 'App bugs, crashes, login problems',
                  ),
                  _HelpTopic(
                    icon: Iconsax.message,
                    title: 'Feedback',
                    subtitle: 'Feature requests and suggestions',
                    isLast: true,
                  ),
                ],
              ),
            ),

            // ── Contact/Social commented ─────
            // const SizedBox(height: TSizes.spaceBtwItems),
            // _SectionLabel(label: 'CONTACT US'),
            // _ContactTile(icon: Icons.email_outlined, iconColor: Colors.orange, title: 'Email Us', subtitle: 'cuexapp@gmail.com', onTap: _openEmail),
            // _ContactTile(icon: Icons.language_rounded, iconColor: Colors.blue, title: 'Website', subtitle: 'www.cuexapp.in', onTap: () => _launch('https://www.cuexapp.in')),

            // const SizedBox(height: TSizes.spaceBtwItems),
            // _SectionLabel(label: 'FOLLOW US'),
            // Row(children: [
            //   _SocialCard(color: Color(0xFFE1306C), icon: Icons.camera_alt_outlined, label: 'Instagram', onTap: () => _launch('https://www.instagram.com/cuexapp')),
            //   SizedBox(width: 8),
            //   _SocialCard(color: Color(0xFF1877F2), icon: Icons.facebook_rounded, label: 'Facebook', onTap: () => _launch('https://www.facebook.com/cuexapp')),
            //   SizedBox(width: 8),
            //   _SocialCard(color: Color(0xFF25D366), icon: Icons.chat_rounded, label: 'WhatsApp', onTap: _openWhatsApp),
            // ]),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Help Topic Row
// ─────────────────────────────────────────────

class _HelpTopic extends StatelessWidget {
  const _HelpTopic({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.isLast = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: TColors.black,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 17, color: TColors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
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
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.35),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            color: Colors.white.withOpacity(0.05),
            indent: 62,
          ),
      ],
    );
  }
}