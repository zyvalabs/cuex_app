import 'package:flutter/material.dart';

import '../../../../../common/widgets/appbar/appbar.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';

class TermsOfUseScreen extends StatelessWidget {
  const TermsOfUseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.peppercorn,
      appBar: TAppBar(
        showBackArrow: true,
        showActions: false,
        showSkipButton: false,
        title: Text('Terms of Use',
            style: Theme.of(context).textTheme.headlineMedium),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF141414),
                borderRadius: BorderRadius.circular(14),
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
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.gavel_outlined,
                            size: 18, color: Colors.red),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Terms of Use',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Last updated: May 2026',
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Please read these Terms of Use carefully before using the CueX application operated by ZyvaLabs. By accessing or using CueX, you agree to be bound by these terms.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwItems),

            _PolicySection(
              title: '1. Acceptance of Terms',
              content: [
                _PolicyItem(
                  body:
                  'By downloading, installing, or using the CueX app, you agree to these Terms of Use and our Privacy Policy. If you do not agree, please do not use the app. These terms apply to all users including players, venue partners, and administrators.',
                ),
              ],
            ),

            _PolicySection(
              title: '2. Eligibility',
              content: [
                _PolicyItem(
                  body:
                  'You must be at least 13 years of age to use CueX. By using the app, you confirm that you meet this requirement. Venue partners must be at least 18 years old and authorized to represent their venue.',
                ),
              ],
            ),

            _PolicySection(
              title: '3. User Accounts',
              content: [
                _PolicyItem(
                  body:
                  '• You are responsible for maintaining the confidentiality of your account credentials\n• You must provide accurate and complete information when registering\n• You are responsible for all activity that occurs under your account\n• You must notify us immediately of any unauthorized use at support@cuexapp.in\n• We reserve the right to suspend or terminate accounts that violate these terms',
                ),
              ],
            ),

            _PolicySection(
              title: '4. Acceptable Use',
              content: [
                _PolicyItem(
                  subtitle: 'You agree NOT to:',
                  body:
                  '• Use CueX for any unlawful purpose or in violation of any regulations\n• Engage in betting, wagering, or gambling of any kind through the app\n• Impersonate any person or entity or misrepresent your affiliation\n• Upload false match results or manipulate leaderboard data\n• Attempt to hack, reverse engineer, or compromise app security\n• Harass, abuse, or harm other users\n• Use automated bots or scripts to access the app\n• Upload inappropriate, offensive, or copyrighted content',
                ),
              ],
            ),

            _PolicySection(
              title: '5. No Betting or Gambling',
              content: [
                _PolicyItem(
                  body:
                  'CueX is strictly a tournament management and live streaming platform for cue sports. We do not facilitate, support, or allow any form of betting, wagering, or staking on match outcomes.\n\nEntry fees shown in the app are participation fees collected by venue organizers directly. CueX is not responsible for the collection or disbursement of any prize money.',
                ),
              ],
            ),

            _PolicySection(
              title: '6. Venue Partners',
              content: [
                _PolicyItem(
                  body:
                  'Venue partners who use CueX agree to:\n\n• Provide accurate venue and event information\n• Manage entry fees and prize money independently and lawfully\n• Comply with all applicable local laws and regulations\n• Not misuse streaming credits or platform features\n• Maintain appropriate conduct toward players and participants',
                ),
              ],
            ),

            _PolicySection(
              title: '7. Live Streaming',
              content: [
                _PolicyItem(
                  body:
                  'CueX integrates with YouTube Live for match streaming. By using streaming features, you agree to:\n\n• Comply with YouTube\'s Terms of Service\n• Stream only lawful content — match footage from your venue\n• Not stream copyrighted music or third-party content without permission\n• Take responsibility for all content streamed through your account',
                ),
              ],
            ),

            _PolicySection(
              title: '8. Intellectual Property',
              content: [
                _PolicyItem(
                  body:
                  'All content in CueX including the app design, logo, code, and features are owned by ZyvaLabs and protected by applicable intellectual property laws. You may not copy, reproduce, or distribute any part of CueX without our written permission.\n\nMatch data and statistics generated through the app may be used by CueX for analytics and improvement purposes.',
                ),
              ],
            ),

            _PolicySection(
              title: '9. Disclaimers',
              content: [
                _PolicyItem(
                  body:
                  'CueX is provided "as is" without warranties of any kind. We do not guarantee:\n\n• Uninterrupted or error-free operation of the app\n• Accuracy of venue, event, or match information provided by partners\n• Availability of streaming features at all times\n• Results of any tournament or event listed on the platform',
                ),
              ],
            ),

            _PolicySection(
              title: '10. Limitation of Liability',
              content: [
                _PolicyItem(
                  body:
                  'To the maximum extent permitted by law, ZyvaLabs shall not be liable for any indirect, incidental, or consequential damages arising from:\n\n• Use or inability to use the app\n• Disputes between players and venue partners\n• Loss of match data due to technical failures\n• Actions of third-party services (Firebase, YouTube)',
                ),
              ],
            ),

            _PolicySection(
              title: '11. Termination',
              content: [
                _PolicyItem(
                  body:
                  'We reserve the right to suspend or terminate your access to CueX at any time, without notice, if you violate these Terms of Use. You may also delete your account at any time through the app settings.',
                ),
              ],
            ),

            _PolicySection(
              title: '12. Governing Law',
              content: [
                _PolicyItem(
                  body:
                  'These Terms of Use are governed by the laws of India. Any disputes arising from the use of CueX shall be subject to the exclusive jurisdiction of courts in Bengaluru, Karnataka, India.',
                ),
              ],
            ),

            _PolicySection(
              title: '13. Changes to Terms',
              content: [
                _PolicyItem(
                  body:
                  'We may update these Terms of Use from time to time. We will notify you of significant changes through the app. Continued use after changes are posted constitutes your acceptance of the new terms.',
                ),
              ],
            ),

            _PolicySection(
              title: '14. Contact Us',
              content: [
                _PolicyItem(
                  body:
                  'If you have any questions about these Terms of Use, please contact us:\n\nEmail: support@cuexapp.in\nWebsite: www.cuexapp.in\nAddress: Bengaluru, Karnataka, India',
                ),
              ],
            ),

            const SizedBox(height: TSizes.spaceBtwSections),

            Center(
              child: Text(
                '© 2026 ZyvaLabs. All rights reserved.',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwSections),
          ],
        ),
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  const _PolicySection({
    required this.title,
    required this.content,
  });

  final String title;
  final List<Widget> content;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: TSizes.spaceBtwItems),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
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
          const SizedBox(height: 10),
          const Divider(color: Color(0xFF1E1E1E), height: 1),
          const SizedBox(height: 10),
          ...content,
        ],
      ),
    );
  }
}

class _PolicyItem extends StatelessWidget {
  const _PolicyItem({this.subtitle, required this.body});

  final String? subtitle;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (subtitle != null) ...[
            Text(
              subtitle!,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 4),
          ],
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