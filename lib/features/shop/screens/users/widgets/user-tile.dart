import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../../../utils/constants/sizes.dart';

import '../../../../personalization/models/user_model.dart';
import 'role_badge.dart';
import 'user_avatar_widget.dart';
import 'verification_badge.dart';

class UserListTile extends StatelessWidget {
  const UserListTile({super.key, required this.user, this.onTap});

  final UserModel user;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(TSizes.md),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(0.15)),
          borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
        ),
        child: Row(
          children: [
            UserAvatarWidget(imageUrl: user.profilePicture, fullName: user.fullName, radius: 26),
            const SizedBox(width: TSizes.spaceBtwItems),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          user.fullName.isNotEmpty ? user.fullName : 'No Name',
                          style: Theme.of(context).textTheme.titleSmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      RoleBadge(role: user.role),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (user.email.isNotEmpty) ...[
                        const Icon(Iconsax.sms, size: 11, color: Colors.grey),
                        const SizedBox(width: 3),
                        Flexible(child: Text(user.email, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey), overflow: TextOverflow.ellipsis)),
                        const SizedBox(width: 8),
                      ],
                      if (user.city.isNotEmpty) ...[
                        const Icon(Iconsax.location, size: 11, color: Colors.grey),
                        const SizedBox(width: 3),
                        Text(user.city, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey)),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      VerificationBadge(status: user.verificationStatus),
                      const Spacer(),
                      if (user.createdAt != null)
                        Text(
                          'Joined ${DateFormat('MMM yyyy').format(user.createdAt!)}',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Iconsax.arrow_right_3, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}