

import 'package:cuex_app/features/shop/screens/event_particapnts/widgets/particapant_status_badge.dart';
import 'package:cuex_app/features/shop/screens/event_particapnts/widgets/payment_update_bottom_sheet.dart';
import 'package:cuex_app/features/shop/screens/event_particapnts/widgets/withdraw_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../personalization/models/user_model.dart';
import '../../../controllers/event_registration_controller.dart';
import '../../../models/event_participant_model.dart';

/// Action sheet for admin/partner
class ParticipantActionSheet extends StatelessWidget {
  const ParticipantActionSheet({super.key,
    required this.participant,
    required this.name,
    required this.user,
    required this.controller,
    required this.onRefresh,
  });

  final EventParticipantModel participant;
  final String name;
  final UserModel? user;
  final EventParticipantController controller;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(99)),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: TSizes.defaultSpace),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: TColors.primary.withOpacity(0.15),
                  backgroundImage:
                  (user?.profilePicture ?? '').isNotEmpty
                      ? NetworkImage(user!.profilePicture)
                      : null,
                  child: (user?.profilePicture ?? '').isEmpty
                      ? Text(name[0].toUpperCase(),
                      style: TextStyle(
                          color: TColors.primary,
                          fontWeight: FontWeight.w600))
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                    child: Text(name,
                        style: Theme.of(context).textTheme.titleSmall)),
                ParticipantStatusBadge(status: participant.status),
              ],
            ),
          ),
          const Divider(height: 24),
          if (participant.status != 'confirmed' &&
              participant.status != 'withdrawn')
            ListTile(
              leading: const Icon(Iconsax.tick_circle, color: Colors.blue),
              title: const Text('Confirm Registration'),
              onTap: () async {
                Navigator.pop(context);
                await controller.updateParticipantStatus(
                    participant.id, 'confirmed');
                onRefresh();
              },
            ),
          if (participant.status != 'withdrawn')
            ListTile(
              leading: const Icon(Iconsax.money, color: Colors.green),
              title: const Text('Update Payment'),
              subtitle: Text('Current: ${participant.paymentStatus}',
                  style: const TextStyle(fontSize: 11)),
              onTap: () async {
                Navigator.pop(context);
                await PaymentUpdateBottomSheet.show(context, participant);
                onRefresh();
              },
            ),
          if (participant.status != 'withdrawn')
            ListTile(
              leading:
              const Icon(Iconsax.user_remove, color: Colors.red),
              title: const Text('Withdraw',
                  style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.pop(context);
                await WithdrawParticipantBottomSheet.show(
                    context, participant);
                onRefresh();
              },
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}