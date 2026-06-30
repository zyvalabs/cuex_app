import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../personalization/controllers/user_controller.dart';


class PlayerQRScreen extends StatelessWidget {
  const PlayerQRScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = UserController.instance.user.value;
    final cuexId = 'CUEX-${user.id.substring(0, 8).toUpperCase()}';

    return Scaffold(
      appBar: AppBar(title: const Text('My QR Code')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              // Avatar
              CircleAvatar(
                radius: 36,
                backgroundColor: TColors.primary.withOpacity(0.15),
                backgroundImage: user.profilePicture.isNotEmpty
                    ? NetworkImage(user.profilePicture)
                    : null,
                child: user.profilePicture.isEmpty
                    ? Text(
                  user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: TColors.primary),
                )
                    : null,
              ),
              const SizedBox(height: 12),
              Text(user.fullName, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(cuexId, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey, letterSpacing: 1.5)),
              const SizedBox(height: TSizes.spaceBtwSections),

              // QR Code
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
                ),
                child: QrImageView(
                  data: user.id,
                  version: QrVersions.auto,
                  size: 220,
                  backgroundColor: Colors.white,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Colors.black,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: TSizes.spaceBtwSections),

              Text(
                'Scan this QR',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}