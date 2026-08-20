import 'package:flutter/material.dart';

/// Shows the logged-in user's profile — picture on the left, name/email/phone
/// stacked on the right. Used at the top of SettingsScreen.
class PlayerCard extends StatelessWidget {
  final String name;
  final String? email;
  final String? phoneNumber;
  final String? profileImageUrl;

  const PlayerCard({
    super.key,
    required this.name,
    this.email,
    this.phoneNumber,
    this.profileImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: Colors.grey.shade300,
          backgroundImage: profileImageUrl != null ? NetworkImage(profileImageUrl!) : null,
          child: profileImageUrl == null
              ? const Icon(Icons.person, color: Colors.grey, size: 32)
              : null,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              if (email != null) ...[
                const SizedBox(height: 4),
                Text(email!, style: const TextStyle(fontSize: 13, color: Colors.grey)),
              ],
              if (phoneNumber != null) ...[
                const SizedBox(height: 2),
                Text(phoneNumber!, style: const TextStyle(fontSize: 13, color: Colors.grey)),
              ],
            ],
          ),
        ),
      ],
    );
  }
}