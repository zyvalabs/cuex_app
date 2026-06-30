import 'package:cuex_app/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'features/shop/screens/live streaming pedro/presentation/screens/streamin_screen.dart';

class StreamScreen extends StatelessWidget {
  const StreamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.peppercorn,
      body: Center(
        child: ElevatedButton(
          onPressed: () => Get.to(() => const StreamingScreen()),
          child: const Text('Start Streaming'),
        ),
      ),
    );
  }
}