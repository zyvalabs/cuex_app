

import 'package:cuex_app/features/shop/screens/event_particapnts/widgets/particapant_status_badge.dart';
import 'package:cuex_app/features/shop/screens/event_particapnts/widgets/payment_status_badge.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../personalization/models/user_model.dart';
import '../../../models/event_participant_model.dart';

/// Single participant row
class ParticipantRow extends StatelessWidget {
  const ParticipantRow({
    required this.participant,
    required this.user,
    required this.isSelected,
    required this.isAdminOrPartner,
    required this.onTap,
  });

  final EventParticipantModel participant;
  final UserModel? user;
  final bool isSelected;
  final bool isAdminOrPartner;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final name = user != null
        ? '${user!.firstName} ${user!.lastName}'.trim()
        : 'Loading...';
    final phone = user?.phoneNumber ?? '';
    final image = user?.profilePicture ?? '';

    return InkWell(
      onTap: onTap,
      child: Container(
        color:
        isSelected ? TColors.primary.withOpacity(0.08) : Colors.transparent,
        padding: const EdgeInsets.symmetric(
            horizontal: TSizes.defaultSpace, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: TColors.primary.withOpacity(0.15),
              backgroundImage:
              image.isNotEmpty ? NetworkImage(image) : null,
              child: image.isEmpty
                  ? Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: TColors.primary),
              )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w500)),
                  if (isAdminOrPartner && phone.isNotEmpty)
                    Text(phone,
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: Colors.grey)),
                ],
              ),
            ),
            if (isAdminOrPartner) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ParticipantStatusBadge(status: participant.status),
                  const SizedBox(height: 4),
                  PaymentStatusBadge(status: participant.paymentStatus),
                ],
              ),
              const SizedBox(width: 8),
              const Icon(Iconsax.arrow_right_3,
                  size: 14, color: Colors.grey),
            ],
            if (isSelected) ...[
              const SizedBox(width: 8),
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                    color: TColors.primary, shape: BoxShape.circle),
                child:
                const Icon(Icons.check, size: 13, color: Colors.white),
              ),
            ],
          ],
        ),
      ),
    );
  }
}