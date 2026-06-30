import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';
import '../../controllers/login_in_controller.dart';
import '../../controllers/phone_number_controller.dart';
import '../phone_number/widget/phone_number_field.dart';


class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  late VideoPlayerController _videoController;
  bool _videoReady = false;
  final _isLoading = false.obs;
  final _isGoogleLoading = false.obs;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  void _initVideo() {
    _videoController = VideoPlayerController.asset('assets/videos/intro.webm')
      ..initialize().then((_) {
        if (mounted) {
          setState(() => _videoReady = true);
          _videoController.setLooping(true);
          _videoController.setVolume(0);
          _videoController.play();
        }
      }).catchError((e) => debugPrint('🔴 Video error: $e'));
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    // ✅ prevent double tap
    if (_isLoading.value) return;

    final signInController = Get.isRegistered<SignInController>()
        ? Get.find<SignInController>()
        : Get.put(SignInController());

    // ✅ validate form first
    if (signInController.signInFormKey.currentState == null) return;
    if (!signInController.signInFormKey.currentState!.validate()) return;

    _isLoading.value = true;
    FocusScope.of(context).unfocus();

    signInController.selectedCountryCode.value = '+91';

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await signInController.loginWithPhoneNumber();
      } catch (e) {
        debugPrint('🔴 sendOtp error: $e');
      } finally {
        if (mounted) _isLoading.value = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final loginController = Get.put(LoginController());
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // ── Video background ──────────────
          if (_videoReady)
            Positioned.fill(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _videoController.value.size.width,
                  height: _videoController.value.size.height,
                  child: VideoPlayer(_videoController),
                ),
              ),
            )
          else
            Positioned.fill(
              child: Container(color: const Color(0xFF0A1A14)),
            ),

          // ── Gradient overlay ──────────────
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.25),
                    Colors.black.withOpacity(0.5),
                    Colors.black.withOpacity(0.9),
                    Colors.black,
                  ],
                  stops: const [0.0, 0.35, 0.65, 1.0],
                ),
              ),
            ),
          ),

          // ── Content ───────────────────────
          SafeArea(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: TSizes.defaultSpace,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: TSizes.spaceBtwSections),

                    // ── Logo ────────────────
                    FadeInDown(
                      duration: const Duration(milliseconds: 600),
                      child: Image.asset(
                        'assets/logos/cuex_logo_final.png',
                        height: 36,
                        fit: BoxFit.contain,
                      ),
                    ),

                    SizedBox(height: size.height * 0.35),

                    // ── Welcome text ─────────
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Welcome!',
                            style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Enter your number to get started.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.45),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: TSizes.spaceBtwSections),

                    // ── Phone field ───────────
                    FadeInUp(
                      delay: const Duration(milliseconds: 200),
                      duration: const Duration(milliseconds: 600),
                      child: const TPhoneNumberField(),
                    ),

                    const SizedBox(height: TSizes.spaceBtwItems),

                    // ── Get OTP button ────────
                    FadeInUp(
                      delay: const Duration(milliseconds: 300),
                      duration: const Duration(milliseconds: 600),
                      child: Obx(() => GestureDetector(
                        onTap: _isLoading.value ? null : _sendOtp,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: double.infinity,
                          padding:
                          const EdgeInsets.symmetric(vertical: 15),
                          decoration: BoxDecoration(
                            color: _isLoading.value
                                ? TColors.june.withOpacity(0.5)
                                : TColors.june,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: _isLoading.value
                                ? []
                                : [
                              BoxShadow(
                                color:
                                TColors.june.withOpacity(0.35),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Center(
                            child: _isLoading.value
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                                : const Text(
                              'Get OTP',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      )),
                    ),

                    const SizedBox(height: TSizes.spaceBtwItems),

                    // ── Divider ───────────────
                    FadeInUp(
                      delay: const Duration(milliseconds: 350),
                      duration: const Duration(milliseconds: 600),
                      child: Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: Colors.white.withOpacity(0.08),
                            ),
                          ),
                          Padding(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'or',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.25),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: Colors.white.withOpacity(0.08),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: TSizes.spaceBtwItems),

                    // ── Google button ─────────
                    FadeInUp(
                      delay: const Duration(milliseconds: 400),
                      duration: const Duration(milliseconds: 600),
                      child: Obx(() => GestureDetector(
                        onTap: _isGoogleLoading.value ? null : () async {
                          _isGoogleLoading.value = true;
                          try {
                            await loginController.googleSignIn();
                          } finally {
                            if (mounted) _isGoogleLoading.value = false;
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A1A),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white.withOpacity(0.08)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: _isGoogleLoading.value
                                ? [const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )]
                                : [
                              Image.asset(TImages.google, width: 22, height: 22),
                              const SizedBox(width: 10),
                              const Text(
                                'Sign in with Google',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
                    ),

                    // ── Email login commented ─
                    // const SizedBox(height: TSizes.spaceBtwItems),
                    // ElevatedButton.icon(
                    //   icon: const Icon(Icons.email_outlined, size: 22),
                    //   onPressed: () => Get.toNamed(TRoutes.logIn, arguments: 'EmailPassword'),
                    //   label: const Text('Login with Email & Password'),
                    //   style: ElevatedButton.styleFrom(
                    //     backgroundColor: TColors.june,
                    //     foregroundColor: Colors.white,
                    //     minimumSize: const Size(double.infinity, 52),
                    //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    //   ),
                    // ),

                    const SizedBox(height: TSizes.spaceBtwSections),

                    // ── Terms ─────────────────
                    FadeInUp(
                      delay: const Duration(milliseconds: 500),
                      duration: const Duration(milliseconds: 600),
                      child: Center(
                        child: Text(
                          'By continuing you agree to our Terms of Service\nand Privacy Policy',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.22),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: TSizes.spaceBtwSections),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}