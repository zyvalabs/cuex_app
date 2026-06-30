import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../../../../../../common/widgets/buttons/streaming_icon_button.dart';
import '../controllers/camera_controller.dart';
class ExposureSliderOverlay extends StatefulWidget {
  const ExposureSliderOverlay({super.key});

  @override
  State<ExposureSliderOverlay> createState() => _ExposureSliderOverlayState();
}

class _ExposureSliderOverlayState extends State<ExposureSliderOverlay> {
  final cameraController = Get.find<CameraController>();
  bool _visible = false;

  void toggle() => setState(() => _visible = !_visible);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        StreamingIconButton(
          icon: Icons.exposure,
          onTap: toggle,
        ),
        if (_visible)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Obx(() {
              final exposure = cameraController.exposureOffset.value;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('$exposure EV',
                      style: const TextStyle(color: Color(0xFF10B981), fontSize: 11)),
                  const SizedBox(height: 4),
                  RotatedBox(
                    quarterTurns: 3,
                    child: SizedBox(
                      width: 120,
                      child: Slider(
                        value: exposure.toDouble(),
                        min: -3, max: 3, divisions: 6,
                        activeColor: const Color(0xFF10B981),
                        inactiveColor: Colors.white24,
                        onChanged: (val) => cameraController.setExposure(val.toInt()),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
      ],
    );
  }
}