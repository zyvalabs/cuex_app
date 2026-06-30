import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../../../../utils/constants/sizes.dart';
import '../../../../personalization/controllers/user_controller.dart';
import '../../../controllers/event_registration_controller.dart';
import '../../../models/event_model.dart';
import '../../../models/event_participant_model.dart';

class EventRegisterButton extends StatelessWidget {
  const EventRegisterButton({super.key, required this.event});
  final EventModel event;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EventParticipantController>();
    final user = UserController.instance.user.value;

    return Padding(
      padding: const EdgeInsets.all(TSizes.defaultSpace),
      child: Obx(() {
        final participant = controller.currentParticipant.value;
        final status = participant?.status;

        // Never registered
        if (participant == null) {
          return _buildButton(
            context,
            label: 'Register Now',
            icon: Iconsax.user_add,
            color: Colors.green,
            onTap: () async {
              await controller.registerForEvent(
                eventId: event.id,
                userId: user.id,
                entryFee: event.entryFee,
              );
            },
          );
        }

        // Registered — pending confirmation
        if (status == 'registered') {
          return _buildButton(
            context,
            label: 'Registered — Pending Confirmation',
            icon: Iconsax.clock,
            color: Colors.orange,
            onTap: () => _showInfoSheet(context, participant),
          );
        }

        // Confirmed
        if (status == 'confirmed') {
          return _buildButton(
            context,
            label: 'Registration Confirmed ✅',
            icon: Iconsax.tick_circle,
            color: Colors.green,
            onTap: () => _showInfoSheet(context, participant),
          );
        }

        // Withdrawn — allow re-register
        if (status == 'withdrawn') {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Info row
              GestureDetector(
                onTap: () => _showInfoSheet(context, participant),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: TSizes.md, vertical: 10),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Iconsax.info_circle, size: 14, color: Colors.red),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Your registration was withdrawn. Tap for details.',
                          style: TextStyle(color: Colors.red, fontSize: 11),
                        ),
                      ),
                      const Icon(Iconsax.arrow_right_3, size: 14, color: Colors.red),
                    ],
                  ),
                ),
              ),
              _buildButton(
                context,
                label: 'Re-Register',
                icon: Iconsax.refresh,
                color: Colors.blue,
                onTap: () async {
                  await controller.registerForEvent(
                    eventId: event.id,
                    userId: user.id,
                    entryFee: event.entryFee,
                  );
                },
              ),
            ],
          );
        }

        // Disqualified
        if (status == 'disqualified') {
          return _buildButton(
            context,
            label: 'Disqualified',
            icon: Iconsax.close_circle,
            color: Colors.red,
            onTap: () => _showInfoSheet(context, participant),
          );
        }

        return const SizedBox.shrink();
      }),
    );
  }

  Widget _buildButton(
      BuildContext context, {
        required String label,
        required IconData icon,
        required Color color,
        VoidCallback? onTap,
      }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: Colors.white, size: 18),
      label: Text(label, style: const TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 52),
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showInfoSheet(BuildContext context, EventParticipantModel participant) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _RegistrationInfoSheet(participant: participant),
    );
  }
}

class _RegistrationInfoSheet extends StatelessWidget {
  const _RegistrationInfoSheet({required this.participant});
  final EventParticipantModel participant;

  Color get _statusColor {
    switch (participant.status) {
      case 'confirmed': return Colors.green;
      case 'withdrawn': return Colors.red;
      case 'disqualified': return Colors.orange;
      default: return Colors.orange;
    }
  }

  Color get _paymentColor {
    switch (participant.paymentStatus) {
      case 'paid': return Colors.green;
      case 'refunded': return Colors.blue;
      case 'waived': return Colors.purple;
      default: return Colors.orange;
    }
  }

  String get _statusLabel {
    switch (participant.status) {
      case 'confirmed': return 'Confirmed ✅';
      case 'withdrawn': return 'Withdrawn ❌';
      case 'disqualified': return 'Disqualified ⛔';
      default: return 'Pending Confirmation ⏳';
    }
  }

  String get _paymentLabel {
    switch (participant.paymentStatus) {
      case 'paid': return 'Paid ✅';
      case 'refunded': return 'Refunded 🔄';
      case 'waived': return 'Waived 🎁';
      default: return 'Pending Payment ⏳';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(TSizes.defaultSpace),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          const SizedBox(height: TSizes.spaceBtwItems),

          // Title
          Row(
            children: [
              const Icon(Iconsax.ticket, size: 20),
              const SizedBox(width: 8),
              Text('Registration Details', style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const Divider(height: 24),

          // Registration status
          _InfoRow(
            icon: Iconsax.user_tick,
            label: 'Registration Status',
            value: _statusLabel,
            valueColor: _statusColor,
          ),
          const SizedBox(height: TSizes.spaceBtwItems),

          // Payment status
          _InfoRow(
            icon: Iconsax.money,
            label: 'Payment Status',
            value: _paymentLabel,
            valueColor: _paymentColor,
          ),
          const SizedBox(height: TSizes.spaceBtwItems),

          // Amount paid
          if (participant.amountPaid != null && participant.amountPaid! > 0) ...[
            _InfoRow(
              icon: Iconsax.money_recive,
              label: 'Amount',
              value: '₹${participant.amountPaid!.toStringAsFixed(0)}',
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
          ],

          // Payment method
          if (participant.paymentMethod != null) ...[
            _InfoRow(
              icon: Iconsax.card,
              label: 'Payment Method',
              value: participant.paymentMethod!.toUpperCase(),
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
          ],

          // Registered at
          _InfoRow(
            icon: Iconsax.calendar,
            label: 'Registered On',
            value: DateFormat('dd MMM yyyy · hh:mm a').format(participant.registeredAt),
          ),
          const SizedBox(height: TSizes.spaceBtwItems),

          // Confirmed at
          if (participant.confirmedAt != null) ...[
            _InfoRow(
              icon: Iconsax.tick_circle,
              label: 'Confirmed On',
              value: DateFormat('dd MMM yyyy · hh:mm a').format(participant.confirmedAt!),
              valueColor: Colors.green,
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
          ],

          // Withdrawal reason
          if (participant.withdrawalReason != null && participant.withdrawalReason!.isNotEmpty) ...[
            _InfoRow(
              icon: Iconsax.info_circle,
              label: 'Withdrawal Reason',
              value: participant.withdrawalReason!,
              valueColor: Colors.red,
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
          ],

          // Notes
          if (participant.notes != null && participant.notes!.isNotEmpty) ...[
            _InfoRow(
              icon: Iconsax.note_text,
              label: 'Notes',
              value: participant.notes!,
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
          ],

          const SizedBox(height: TSizes.spaceBtwItems),

          // Close button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ),
          const SizedBox(height: TSizes.spaceBtwItems),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}