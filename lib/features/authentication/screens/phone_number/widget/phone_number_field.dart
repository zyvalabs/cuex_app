import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/constants/text_strings.dart';
import '../../../../../utils/helpers/helper_functions.dart';
import '../../../../../utils/validators/validation.dart';
import '../../../controllers/phone_number_controller.dart';

class TPhoneNumberField extends StatelessWidget {
  const TPhoneNumberField({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = THelperFunctions.isDarkMode(context);
    final controller = Get.put(SignInController());

    return Form(
      key: controller.signInFormKey,
      child: TextFormField(
        cursorColor: TColors.june,
        cursorHeight: TSizes.lg,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        validator: (value) => TValidator.validatePhoneNumber(value),
        controller: controller.phone,
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(
          fillColor: const Color(0xFF1A1A1A),
          filled: true,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: TColors.june.withOpacity(0.6)),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: TColors.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: TColors.error),
          ),
          prefixIcon: CountryCodePicker(
            alignLeft: false,
            hideMainText: false,
            showCountryOnly: false,
            showFlagMain: true,       // ✅ hide flag
            showFlag: true,           // ✅ hide flag in dropdown
            showDropDownButton: false, // ✅ hide chevron
            padding: EdgeInsets.zero,
            initialSelection: '+91',  // ✅ India default
            favorite: const ['+91'],
            onChanged: (value) =>
            controller.selectedCountryCode.value = value.dialCode!,
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            searchDecoration: InputDecoration(
              fillColor: isDark ? TColors.darkContainer : TColors.lightContainer,
            ),
            dialogBackgroundColor: isDark ? TColors.dark : TColors.light,
            headerText: TTexts.selectCountry,
          ),
          hintText: TTexts.phoneNo,
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.25),
            fontWeight: FontWeight.w400,
          ),
          errorStyle: const TextStyle(color: TColors.error),
        ),
      ),
    );
  }
}