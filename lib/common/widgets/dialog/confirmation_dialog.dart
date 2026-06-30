// lib/shared/widgets/dialogs/confirmation_dialog.dart
import 'package:flutter/material.dart';


import '../../../utils/constants/colors.dart';
import '../buttons/app_button.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final bool isDangerous;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    required this.onConfirm,
    this.isDangerous = false,
  });

  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDangerous = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: () => Navigator.pop(context, true),
        isDangerous: isDangerous,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: TColors.darkGrey,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isDangerous)
              Icon(
                Icons.warning_rounded,
                color: TColors.darkGrey,
                size: 48,
              ),
            if (isDangerous) SizedBox(height: 16),
            Text(
              title,

              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
           Text(
              message,

              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: cancelText,
                    isOutlined: true,
                    onPressed: () => Navigator.pop(context, false),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    text: confirmText,
                    backgroundColor: isDangerous ? TColors.darkGrey : null,
                    onPressed: onConfirm,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}