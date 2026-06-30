import 'package:cuex_app/features/shop/screens/event_particapnts/widgets/particapant_status_badge.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../utils/constants/enums.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../personalization/controllers/user_controller.dart';
import '../../../../personalization/models/user_model.dart';
import '../../../models/event_participant_model.dart';

import 'payment_status_badge.dart';

class ParticipantCard extends StatelessWidget {
  const ParticipantCard({
    super.key,
    required this.participant,
    this.resolvedUser,
    this.isSelected = false,
    this.singleSelect = false,
    this.onTap,
    this.onPaymentTap,
    this.onWithdrawTap,
  });

  final EventParticipantModel participant;
  final UserModel? resolvedUser;
  final bool isSelected;
  final bool singleSelect;
  final VoidCallback? onTap;
  final VoidCallback? onPaymentTap;
  final VoidCallback? onWithdrawTap;

  @override
  Widget build(BuildContext context) {
    final role = UserController.instance.user.value.role;
    final isAdminOrPartner = role == AppRole.admin || role == AppRole.partner;
    final name = resolvedUser != null
        ? '${resolvedUser!.firstName} ${resolvedUser!.lastName}'.trim()
        : 'Loading...';
    final phone = resolvedUser?.phoneNumber ?? '';
    final image = resolvedUser?.profilePicture ?? '';

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(TSizes.md),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : const Color(0xFF13131F),
          borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor.withOpacity(0.5)
                : Colors.white.withOpacity(0.08),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 22,
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.15),
                  backgroundImage: image.isNotEmpty ? NetworkImage(image) : null,
                  child: image.isEmpty
                      ? Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColor,
                    ),
                  )
                      : null,
                ),
                const SizedBox(width: TSizes.spaceBtwItems),

                // Name + badges
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      if (isAdminOrPartner && phone.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Iconsax.call, size: 12, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(phone, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey)),
                          ],
                        ),
                      ],
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          ParticipantStatusBadge(status: participant.status),
                          const SizedBox(width: 6),
                          PaymentStatusBadge(status: participant.paymentStatus),
                        ],
                      ),
                    ],
                  ),
                ),

                // Selection indicator
                if (isSelected)
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, size: 14, color: Colors.white),
                  ),
              ],
            ),

            // Admin/Partner actions
            if (isAdminOrPartner && participant.status != 'withdrawn') ...[
              const SizedBox(height: TSizes.sm),
              const Divider(color: Colors.white10, height: 1),
              const SizedBox(height: TSizes.sm),
              Row(
                children: [
                  // Payment action
                  Expanded(
                    child: GestureDetector(
                      onTap: onPaymentTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.withOpacity(0.2)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Iconsax.money, size: 14, color: Colors.green),
                            const SizedBox(width: 4),
                            Text(
                              participant.paymentStatus == 'paid' ? 'Payment Done' : 'Mark Payment',
                              style: const TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Confirm action
                  if (participant.status != 'confirmed')
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          // confirm participant inline
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 7),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.withOpacity(0.2)),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Iconsax.tick_circle, size: 14, color: Colors.blue),
                              SizedBox(width: 4),
                              Text('Confirm', style: TextStyle(fontSize: 11, color: Colors.blue, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),

                  // Withdraw action
                  GestureDetector(
                    onTap: onWithdrawTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.withOpacity(0.2)),
                      ),
                      child: const Icon(Iconsax.user_remove, size: 16, color: Colors.red),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}