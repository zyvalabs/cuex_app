// lib/features/streaming/presentation/widgets/quality_selector_dialog.dart

import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';

import '../../../../../../data/services/streaming/streaming_service.dart';
import '../controllers/preview_controller.dart';

Future<void> showQualitySelectorDialog(BuildContext context) async {
  final previewController = Get.find<PreviewController>();
  final currentQuality = previewController.selectedResolution.value;

  final capabilities = await StreamingService.getCameraCapabilities();
  if (capabilities == null || !context.mounted) return;

  final resolutions = capabilities['resolutions'] as List;

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => Container(
      decoration: const BoxDecoration(
        color: Color(0xFF111827),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Stream Quality',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...resolutions.map((res) {
              final label = res['label'] as String;
              final isSelected = label == currentQuality;
              return GestureDetector(
                onTap: () {
                  previewController.updateQuality(
                    resolution: label,
                    width: res['width'] as int,
                    height: res['height'] as int,
                  );
                  Navigator.pop(context);
                  Get.snackbar('Quality Updated', 'Set to $label',
                      snackPosition: SnackPosition.BOTTOM,
                      duration: const Duration(seconds: 2));
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF10B981).withOpacity(0.15)
                        : const Color(0xFF1F2937),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF10B981) : Colors.white12,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                        color: isSelected ? const Color(0xFF10B981) : Colors.white38,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(label,
                              style: TextStyle(
                                color: isSelected ? const Color(0xFF10B981) : Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              )),
                          Text('${res['width']}x${res['height']}',
                              style: TextStyle(
                                color: isSelected
                                    ? const Color(0xFF10B981).withOpacity(0.7)
                                    : Colors.white38,
                                fontSize: 12,
                              )),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    ),
  );
}