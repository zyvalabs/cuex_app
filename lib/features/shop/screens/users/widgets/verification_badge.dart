import 'package:flutter/material.dart';
import '../../../../../utils/constants/enums.dart';

class VerificationBadge extends StatelessWidget {
  const VerificationBadge({super.key, required this.status});
  final VerificationStatus status;

  Color get _color {
    switch (status) {
      case VerificationStatus.approved: return Colors.green;
      case VerificationStatus.pending: return Colors.orange;
      case VerificationStatus.rejected: return Colors.red;
      case VerificationStatus.submitted: return Colors.blue;
      case VerificationStatus.underReview: return Colors.amber;
      case VerificationStatus.unknown: return Colors.grey;
    }
  }

  String get _label {
    switch (status) {
      case VerificationStatus.approved: return 'Verified';
      case VerificationStatus.pending: return 'Pending';
      case VerificationStatus.rejected: return 'Rejected';
      case VerificationStatus.submitted: return 'Submitted';
      case VerificationStatus.underReview: return 'Under Review';
      case VerificationStatus.unknown: return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: _color.withOpacity(0.3)),
      ),
      child: Text(
        _label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _color),
      ),
    );
  }
}