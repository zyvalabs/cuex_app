import 'package:cuex_app/controllers/match_setup_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/match_creation_controller.dart';


/// Round Name field — only shown when this match is being created inside
/// an event (e.g. "Round of 16", "Quarterfinal", "Final"). Free text since
/// round naming conventions vary by tournament format.
class RoundNameSection extends StatelessWidget {
  const RoundNameSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MatchSetupController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Round Name', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
        const SizedBox(height: 8),
        TextField(
          controller: controller.roundNameController,
          decoration: InputDecoration(
            hintText: 'e.g. Round of 16, Quarterfinal, Final',
            filled: true,
            fillColor: const Color(0xFFF2F2F2),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}