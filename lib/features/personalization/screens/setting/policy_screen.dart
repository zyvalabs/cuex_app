import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../common/widgets/appbar/appbar.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.peppercorn,
      appBar: TAppBar(
        showBackArrow: true,
        showActions: false,
        showSkipButton: false,
        title: Text('Privacy Policy',
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
                        child: const Icon(Icons.privacy_tip_outlined,
                            size: 18, color: Colors.red),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Privacy Policy',
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
                    'This Privacy Policy describes how ZyvaLabs ("we", "us", or "our") collects, uses, and shares information about you when you use the CueX mobile application.',
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
              title: '1. Information We Collect',
              content: [
                _PolicyItem(
                  subtitle: 'Personal Information',
                  body:
                  'When you register, we collect your full name, email address, phone number, and profile picture. This information is used to create and manage your account.',
                ),
                _PolicyItem(
                  subtitle: 'Match & Game Data',
                  body:
                  'We collect match statistics, scores, break records, and performance data to provide leaderboards and player stats features.',
                ),
                _PolicyItem(
                  subtitle: 'Location Information',
                  body:
                  'With your permission, we collect location data to help you discover nearby snooker and billiards venues.',
                ),
                _PolicyItem(
                  subtitle: 'Device Information',
                  body:
                  'We collect device identifiers (FCM token) to send you push notifications about matches, events, and updates.',
                ),
              ],
            ),

            _PolicySection(
              title: '2. How We Use Your Information',
              content: [
                _PolicyItem(
                  body:
                  '• To create and manage your CueX account\n• To display your match history, statistics, and leaderboard ranking\n• To send notifications about events, draws, results, and match updates\n• To connect players with venues and tournaments\n• To improve app features and user experience\n• To provide customer support',
                ),
              ],
            ),

            _PolicySection(
              title: '3. Data Storage & Third-Party Services',
              content: [
                _PolicyItem(
                  body:
                  'Your data is stored securely using Google Firebase services (Firestore, Firebase Storage, Firebase Auth), which may store data on servers outside India. By using CueX, you consent to this transfer.',
                ),
                _PolicyItem(
                  subtitle: 'Third-party services we use:',
                  body:
                  '• Google Firebase (authentication, database, storage)\n• Google Sign-In (optional login)\n• YouTube Live API (streaming features)\n• Firebase Cloud Messaging (push notifications)',
                ),
              ],
            ),

            _PolicySection(
              title: '4. Data Sharing',
              content: [
                _PolicyItem(
                  body:
                  'We do not sell your personal data to third parties. We may share data with:\n\n• Venue partners — to manage event registrations (name, contact only)\n• Service providers — only as necessary to operate the app\n• Legal authorities — if required by law under the Information Technology Act, 2000',
                ),
              ],
            ),

            _PolicySection(
              title: '5. Your Rights',
              content: [
                _PolicyItem(
                  body:
                  'You have the right to:\n\n• Access your personal data stored in CueX\n• Request correction of inaccurate information\n• Request deletion of your account and associated data\n• Withdraw consent for notifications at any time\n\nTo exercise these rights, contact us at privacy@cuexapp.in',
                ),
              ],
            ),

            _PolicySection(
              title: '6. Data Retention',
              content: [
                _PolicyItem(
                  body:
                  'We retain your personal data for as long as your account is active. Match statistics and historical data may be retained for analytical purposes after account deletion, in anonymized form.',
                ),
              ],
            ),

            _PolicySection(
              title: '7. Children\'s Privacy',
              content: [
                _PolicyItem(
                  body:
                  'CueX is not intended for users under 13 years of age. We do not knowingly collect personal information from children under 13.',
                ),
              ],
            ),

            _PolicySection(
              title: '8. Security',
              content: [
                _PolicyItem(
                  body:
                  'We implement industry-standard security measures including encrypted data transmission (HTTPS), Firebase security rules, and authenticated access controls to protect your information.',
                ),
              ],
            ),

            _PolicySection(
              title: '9. Grievance Officer',
              content: [
                _PolicyItem(
                  body:
                  'In accordance with the Information Technology Act, 2000 and rules made thereunder, the name and contact details of the Grievance Officer are:\n\nName: Mohammed Tanveer\nOrganization: ZyvaLabs\nEmail: support@cuexapp.in\nResponse time: Within 30 days of receipt of complaint',
                ),
              ],
            ),

            _PolicySection(
              title: '10. Changes to This Policy',
              content: [
                _PolicyItem(
                  body:
                  'We may update this Privacy Policy from time to time. We will notify you of any significant changes through the app or by email. Continued use of CueX after changes constitutes acceptance of the updated policy.',
                ),
              ],
            ),

            _PolicySection(
              title: '11. Contact Us',
              content: [
                _PolicyItem(
                  body:
                  'If you have any questions about this Privacy Policy, please contact us:\n\nEmail: support@cuexapp.in\nWebsite: www.cuexapp.in\nAddress: Bengaluru, Karnataka, India',
                ),
              ],
            ),

            const SizedBox(height: TSizes.spaceBtwSections),

            // Footer
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