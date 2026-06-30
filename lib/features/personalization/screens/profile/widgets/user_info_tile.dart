import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../controllers/user_controller.dart';
import '../../../models/user_model.dart';
class UserInfoTile extends StatelessWidget {
  const UserInfoTile({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel>(
      future: UserController.instance.getUserById(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        final user = snapshot.data ?? UserModel.empty();
        return Container(
          padding: const EdgeInsets.all(TSizes.md),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
          ),
          child: Row(
            children: [
              /// Profile Image
              ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: user.profilePicture.isNotEmpty
                    ? Image.network(user.profilePicture, width: 44, height: 44, fit: BoxFit.cover)
                    : Container(width: 44, height: 44, color: TColors.darkGrey, child: const Icon(Iconsax.user, color: Colors.white)),
              ),
              const SizedBox(width: TSizes.spaceBtwItems),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.fullName, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(user.phoneNumber.isNotEmpty ? user.phoneNumber : user.email,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.grey)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}