import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../utils/constants/sizes.dart';

class FrameSelector extends StatelessWidget {
  const FrameSelector({
    super.key,
    required this.frames,
    required this.onChanged,
  });

  final Rx<int?> frames;
  final void Function(int?) onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: 'Enter Total Frames',
        prefixIcon: Icon(Iconsax.frame, size: 18),
        hintText: 'e.g. 5, 7, 9',
      ),
      onChanged: (val) => onChanged(int.tryParse(val)),
      validator: (val) {
        if (val == null || val.isEmpty) return 'Please enter total frames';
        if (int.tryParse(val) == null || int.parse(val) <= 0) return 'Enter a valid number';
        return null;
      },
    );
  }
}