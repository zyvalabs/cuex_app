import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

import '../../common/widgets/loaders/animation_loader.dart';
import '../../common/widgets/loaders/circular_loader.dart';
import '../constants/colors.dart';

class TFullScreenLoader {
  static bool _isOpen = false;

  // ── Open full screen loading dialog ──────
  static void openLoadingDialog(String text, String animation) {
    if (_isOpen) return; // ✅ prevent double open
    final context = _overlayContext;
    if (context == null) return;

    _isOpen = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      builder: (_) => PopScope(
        canPop: false,
        child: Container(
          color: TColors.knightBlack,
          width: double.infinity,
          height: double.infinity,
          child: Column(
            children: [
              const SizedBox(height: 250),
              TAnimationLoaderWidget(text: text, animation: animation),
            ],
          ),
        ),
      ),
    ).then((_) => _isOpen = false); // ✅ reset flag when closed
  }

  // ── Open circular loader ──────────────────
  static void popUpCircular() {
    if (_isOpen) return;
    final context = _overlayContext;
    if (context == null) return;

    _isOpen = true;
    showDialog(
      context: context,
      barrierDismissible: false,

      builder: (_) => const PopScope(
        canPop: false,
        child: Center(child: TCircularLoader()),
      ),
    ).then((_) => _isOpen = false);
  }

  // ── Stop loading ──────────────────────────
  static void stopLoading() {
    if (!_isOpen) return; // ✅ don't pop if nothing open
    final context = _overlayContext;
    if (context == null) return;

    try {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint('🔴 stopLoading error: $e');
    } finally {
      _isOpen = false;
    }
  }

  // ── Safe overlay context ──────────────────
  static BuildContext? get _overlayContext {
    return Get.overlayContext;
  }
}