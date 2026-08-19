import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/widgets/buttons/app_button.dart';
import '../../../controllers/match_creation_controller.dart';
import '../../../core/utils/constants/app_colors.dart';
import '../../../core/widgets/step/step_widget.dart';
import '../../../core/widgets/title/section_title_widget.dart';
import '../../../widgets/common/custom_app_bar.dart';
import '../../matches/match_detail_screen.dart';


/// Thin screen — Server URL + Stream Key fields, wired directly to controller.
class RtmpSetupScreen extends StatefulWidget {
  const RtmpSetupScreen({super.key});

  @override
  State<RtmpSetupScreen> createState() => _RtmpSetupScreenState();
}

class _RtmpSetupScreenState extends State<RtmpSetupScreen> {
  final controller = Get.find<MatchCreationController>();
  late final TextEditingController urlController;
  late final TextEditingController keyController;

  @override
  void initState() {
    super.initState();
    urlController = TextEditingController(text: controller.rtmpUrl.value);
    keyController = TextEditingController(text: controller.streamKey.value);
  }

  @override
  void dispose() {
    urlController.dispose();
    keyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CustomAppBar(
        backgroundColor: AppColors.green,
        title: 'New Match',
        showBackButton: true,
        rightActions: [
          IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: Obx(() => AppButton(
          text: 'Go Live',
          onPressed: controller.isRtmpSetupValid
              ? () async {
            final matchId = await controller.createMatch();
            if (matchId != null) {
              if (context.mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MatchDetailsScreen()),
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(controller.saveError.value ?? 'Failed to create match')),
              );
            }
          }
              : null,
        )),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              const StepWidget(totalSteps: 4, currentStep: 4),
              const SizedBox(height: 24),
              const SectionTitleWidget(
                title: 'Setup RTMP Stream',
                textAlign: TextAlign.left,
              ),

              const Text('Server URL', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              const SizedBox(height: 8),
              TextField(
                controller: urlController,
                onChanged: (val) {
                  controller.setRtmpUrl(val);
                  setState(() {}); // refresh Go Live button state
                },
                decoration: InputDecoration(
                  hintText: 'rtmp://...',
                  filled: true,
                  fillColor: const Color(0xFFF2F2F2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text('Stream Key', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              const SizedBox(height: 8),
              TextField(
                controller: keyController,
                obscureText: true,
                onChanged: (val) {
                  controller.setStreamKey(val);
                  setState(() {}); // refresh Go Live button state
                },
                decoration: InputDecoration(
                  hintText: 'Enter stream key',
                  filled: true,
                  fillColor: const Color(0xFFF2F2F2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}