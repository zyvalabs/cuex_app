import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../utils/constants/sizes.dart';
import '../../../controllers/event_registration_controller.dart';
import '../../../models/event_participant_model.dart';

class PaymentUpdateBottomSheet extends StatefulWidget {
  const PaymentUpdateBottomSheet({super.key, required this.participant});
  final EventParticipantModel participant;

  static Future<void> show(BuildContext context, EventParticipantModel participant) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => PaymentUpdateBottomSheet(participant: participant),
    );
  }

  @override
  State<PaymentUpdateBottomSheet> createState() => _PaymentUpdateBottomSheetState();
}

class _PaymentUpdateBottomSheetState extends State<PaymentUpdateBottomSheet> {
  final amountController = TextEditingController();
  final transactionController = TextEditingController();
  String selectedMethod = 'cash';
  String selectedStatus = 'paid';
  bool isLoading = false;

  final methods = ['cash', 'upi', 'card', 'online'];
  final statuses = ['paid', 'pending', 'refunded', 'waived'];

  @override
  void initState() {
    super.initState();
    amountController.text = widget.participant.amountPaid?.toString() ?? '';
    transactionController.text = widget.participant.transactionId ?? '';
    selectedMethod = widget.participant.paymentMethod ?? 'cash';
    selectedStatus = widget.participant.paymentStatus;
  }

  @override
  void dispose() {
    amountController.dispose();
    transactionController.dispose();
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
              const Icon(Iconsax.money, size: 20),
              const SizedBox(width: 8),
              Text('Update Payment', style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, size: 20)),
            ],
          ),
          const Divider(),
          const SizedBox(height: TSizes.spaceBtwItems),

          // Payment status
          Text('Payment Status', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.grey)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: statuses.map((s) {
              final isSelected = selectedStatus == s;
              return GestureDetector(
                onTap: () => setState(() => selectedStatus = s),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.15) : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(
                      color: isSelected ? Theme.of(context).primaryColor : Colors.grey.withOpacity(0.2),
                    ),
                  ),
                  child: Text(
                    s[0].toUpperCase() + s.substring(1),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: TSizes.spaceBtwItems),

          // Amount
          TextFormField(
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Amount Paid (₹)',
              prefixIcon: Icon(Iconsax.money_recive, size: 18),
            ),
          ),
          const SizedBox(height: TSizes.spaceBtwInputFields),

          // Payment method
          Text('Payment Method', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.grey)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: methods.map((m) {
              final isSelected = selectedMethod == m;
              return GestureDetector(
                onTap: () => setState(() => selectedMethod = m),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.15) : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(
                      color: isSelected ? Theme.of(context).primaryColor : Colors.grey.withOpacity(0.2),
                    ),
                  ),
                  child: Text(
                    m.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: TSizes.spaceBtwInputFields),

          // Transaction ID
          TextFormField(
            controller: transactionController,
            decoration: const InputDecoration(
              labelText: 'Transaction ID (Optional)',
              prefixIcon: Icon(Iconsax.receipt, size: 18),
            ),
          ),
          const SizedBox(height: TSizes.spaceBtwSections),

          // Save button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading ? null : _save,
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              child: isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Save Payment'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    setState(() => isLoading = true);
    try {
      await EventParticipantController.instance.updatePaymentStatus(
        participantId: widget.participant.id,
        paymentStatus: selectedStatus,
        amountPaid: double.tryParse(amountController.text.trim()),
        paymentMethod: selectedMethod,
        transactionId: transactionController.text.trim().isNotEmpty
            ? transactionController.text.trim()
            : null,
      );
      if (mounted) Navigator.pop(context);
    } finally {
      setState(() => isLoading = false);
    }
  }
}