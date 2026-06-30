import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../utils/constants/sizes.dart';
import '../../../controllers/event_registration_controller.dart';
import '../../../models/event_participant_model.dart';

class WithdrawParticipantBottomSheet extends StatefulWidget {
  const WithdrawParticipantBottomSheet({super.key, required this.participant});
  final EventParticipantModel participant;

  static Future<void> show(BuildContext context, EventParticipantModel participant) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => WithdrawParticipantBottomSheet(participant: participant),
    );
  }

  @override
  State<WithdrawParticipantBottomSheet> createState() => _WithdrawParticipantBottomSheetState();
}

class _WithdrawParticipantBottomSheetState extends State<WithdrawParticipantBottomSheet> {
  final reasonController = TextEditingController();
  bool isLoading = false;

  final reasons = [
    'Player request',
    'No show',
    'Payment not received',
    'Disqualified',
    'Other',
  ];
  String? selectedReason;

  @override
  void dispose() {
    reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        TSizes.defaultSpace,
        TSizes.defaultSpace,
        TSizes.defaultSpace,
        TSizes.defaultSpace + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Header
          Row(
            children: [
              const Icon(Iconsax.user_remove, size: 20, color: Colors.red),
              const SizedBox(width: 8),
              Text('Withdraw Participant', style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, size: 20)),
            ],
          ),
          const Divider(),
          const SizedBox(height: TSizes.spaceBtwItems),

          // Warning
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(TSizes.md),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.08),
              borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
              border: Border.all(color: Colors.red.withOpacity(0.2)),
            ),
            child: const Row(
              children: [
                Icon(Iconsax.warning_2, size: 16, color: Colors.red),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'This will remove the player from the event and notify them.',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: TSizes.spaceBtwItems),

          // Reason chips
          Text('Reason', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.grey)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: reasons.map((r) {
              final isSelected = selectedReason == r;
              return GestureDetector(
                onTap: () => setState(() {
                  selectedReason = r;
                  if (r != 'Other') reasonController.text = r;
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.red.withOpacity(0.1) : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(
                      color: isSelected ? Colors.red.withOpacity(0.4) : Colors.grey.withOpacity(0.2),
                    ),
                  ),
                  child: Text(
                    r,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.red : Colors.grey,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: TSizes.spaceBtwInputFields),

          // Custom reason
          if (selectedReason == 'Other')
            TextFormField(
              controller: reasonController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Enter reason',
                prefixIcon: Icon(Iconsax.document_text, size: 18),
                alignLabelWithHint: true,
              ),
            ),
          const SizedBox(height: TSizes.spaceBtwSections),

          // Confirm button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading || selectedReason == null ? null : _withdraw,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.red,
              ),
              child: isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Confirm Withdrawal', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _withdraw() async {
    final reason = reasonController.text.trim().isNotEmpty
        ? reasonController.text.trim()
        : selectedReason ?? '';
    setState(() => isLoading = true);
    try {
      await EventParticipantController.instance.withdrawFromEvent(
        widget.participant.id,
        reason,
      );
      if (mounted) Navigator.pop(context);
    } finally {
      setState(() => isLoading = false);
    }
  }
}