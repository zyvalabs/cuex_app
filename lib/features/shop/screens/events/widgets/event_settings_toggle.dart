import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../utils/constants/enums.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../controllers/event_controller.dart';
import '../../../../personalization/controllers/user_controller.dart';

class EventSettingsToggles extends StatelessWidget {
  const EventSettingsToggles({super.key});

  @override
  Widget build(BuildContext context) {
    final c = EventController.instance;
    final isAdmin = UserController.instance.user.value.role == AppRole.admin;

    return Obx(() => Column(
      children: [
        _toggle(
          context,
          icon: Iconsax.global,
          title: 'Public Event',
          subtitle: 'Visible to all players',
          value: c.isPublic.value,
          onChanged: (val) => c.isPublic.value = val,
        ),
        const SizedBox(height: TSizes.sm),
        if (isAdmin) ...[
          _toggle(
            context,
            icon: Iconsax.star,
            title: 'Featured Event',
            subtitle: 'Show on home screen',
            value: c.isFeatured.value,
            onChanged: (val) => c.isFeatured.value = val,
          ),
          const SizedBox(height: TSizes.sm),
          _toggle(
            context,
            icon: Iconsax.shield_tick,
            title: 'Verified',
            subtitle: 'Mark as admin verified',
            value: c.isVerified.value,
            onChanged: (val) => c.isVerified.value = val,
          ),
          const SizedBox(height: TSizes.sm),
          _toggle(
            context,
            icon: Iconsax.code,
            title: 'Testing Mode',
            subtitle: 'Hidden from players, admin only',
            value: c.isTesting.value,
            onChanged: (val) => c.isTesting.value = val,
          ),
        ],
      ],
    ));
  }

  Widget _toggle(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required bool value,
        required void Function(bool) onChanged,
      }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
        borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
      ),
      child: SwitchListTile(
        secondary: Icon(icon, size: 20, color: value ? Theme.of(context).primaryColor : Colors.grey),
        title: Text(title, style: Theme.of(context).textTheme.bodyMedium),
        subtitle: Text(subtitle, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey)),
        value: value,
        onChanged: onChanged,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(TSizes.cardRadiusMd)),
      ),
    );
  }
}