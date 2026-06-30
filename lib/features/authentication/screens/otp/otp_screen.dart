import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sms_autofill/sms_autofill.dart';

import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../controllers/otp_controller.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> with CodeAutoFill {
  late final OTPController controller;
  final _codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller = OTPController.instance;
    controller.init();
    _startAutoFill();
  }

  Future<void> _startAutoFill() async {
    final signature = await SmsAutoFill().getAppSignature;
    print('📍 App signature: $signature'); // ✅ add this
    await SmsAutoFill().listenForCode();
  }

  // ── Auto called when SMS arrives ──────────
  @override
  void codeUpdated() {
    if (code != null && code!.length == 6) {
      _codeController.text = code!;
      controller.otp = code!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.verifyOTP();
      });
    }
  }

  @override
  void dispose() {
    SmsAutoFill().unregisterListener();
    _codeController.dispose();
    cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // ── Back ──────────────────────
              GestureDetector(
                onTap: () => Navigator.of(context).pop(false),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.08),
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 16,
                    color: Colors.white70,
                  ),
                ),
              ),
              const SizedBox(height: TSizes.spaceBtwSections),

              // ── Title ─────────────────────
              const Text(
                'Verify your\nnumber',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.15,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 10),
              Obx(() => RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.4),
                    height: 1.5,
                  ),
                  children: [
                    const TextSpan(text: 'Code sent to '),
                    TextSpan(
                      text: THelperFunctions.maskPhoneNumber(
                        controller.phoneNumber.value,
                      ),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )),
              const SizedBox(height: 32),

              // ── OTP field with auto-fill ───
              PinFieldAutoFill(
                controller: _codeController,
                codeLength: 6,
                decoration: UnderlineDecoration(
                  textStyle: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  colorBuilder: FixedColorBuilder(Colors.white.withOpacity(0.08)),
                  // selectedColorBuilder: FixedColorBuilder(TColors.june),
                  // strokeWidth: 2,
                ),
                onCodeChanged: (code) {
                  if (code != null) controller.otp = code;
                },
                onCodeSubmitted: (code) {
                  controller.otp = code;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    controller.verifyOTP();
                  });
                },
              ),

              const SizedBox(height: 12),

              // ── Auto-fill hint ────────────
              Row(
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    size: 12,
                    color: TColors.june.withOpacity(0.6),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'OTP will be filled automatically',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: TSizes.spaceBtwSections),

              // ── Verify button ─────────────
              Obx(() => GestureDetector(
                onTap: controller.loader.value
                    ? null
                    : () {
                  WidgetsBinding.instance
                      .addPostFrameCallback((_) {
                    controller.verifyOTP();
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: controller.loader.value
                        ? TColors.june.withOpacity(0.4)
                        : TColors.june,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: controller.loader.value
                        ? []
                        : [
                      BoxShadow(
                        color: TColors.june.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: controller.loader.value
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Text(
                      'Verify & Continue',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              )),

              const SizedBox(height: TSizes.spaceBtwSections),

              // ── Resend ────────────────────
              Center(
                child: Obx(() => GestureDetector(
                  onTap: controller.secondsRemaining.value > 0
                      ? null
                      : () => controller.resendOTP(),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.35),
                      ),
                      children: [
                        const TextSpan(text: "Didn't receive? "),
                        TextSpan(
                          text: controller.secondsRemaining.value > 0
                              ? 'Resend in ${controller.secondsRemaining.value}s'
                              : 'Resend OTP',
                          style: TextStyle(
                            color:
                            controller.secondsRemaining.value > 0
                                ? Colors.white.withOpacity(0.25)
                                : TColors.june,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}