import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../controllers/coupons_controller.dart';


class AddCouponScreen extends StatelessWidget {
  const AddCouponScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CouponsController());

    return Scaffold(
      backgroundColor: TColors.peppercorn,
      appBar: TAppBar(
        showBackArrow: true,
        title: Text('Add Coupon', style: Theme.of(context).textTheme.headlineMedium),
        showActions: false,
        showSkipButton: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Form(
          key: controller.addCouponFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// Coupon Code
              TextFormField(
                controller: controller.couponCode,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Coupon Code',
                  prefixIcon: Icon(Iconsax.discount_shape),
                  hintText: 'e.g. SAVE20',
                ),
                validator: (v) => v!.isEmpty ? 'Enter coupon code' : null,
              ),
              const SizedBox(height: TSizes.spaceBtwSections),

              /// Discount Type
              Text('Discount Type', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: TSizes.spaceBtwItems),
              Obx(() => Row(
                children: ['flat', 'percentage'].map((type) {
                  final isSelected = controller.selectedDiscountType.value == type;
                  return GestureDetector(
                    onTap: () => controller.selectedDiscountType.value = type,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: TSizes.sm),
                      padding: const EdgeInsets.symmetric(horizontal: TSizes.lg, vertical: TSizes.sm),
                      decoration: BoxDecoration(
                        color: isSelected ? TColors.primary.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
                        border: Border.all(color: isSelected ? TColors.primary : Colors.transparent),
                      ),
                      child: Text(
                        type == 'flat' ? 'Flat (₹)' : 'Percentage (%)',
                        style: TextStyle(color: isSelected ? TColors.primary : Colors.white),
                      ),
                    ),
                  );
                }).toList(),
              )),
              const SizedBox(height: TSizes.spaceBtwInputFields),

              /// Discount Value
              TextFormField(
                controller: controller.discountValue,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Discount Value',
                  prefixIcon: const Icon(Iconsax.money),
                  suffixText: controller.selectedDiscountType.value == 'percentage' ? '%' : '₹',
                ),
                validator: (v) => v!.isEmpty ? 'Enter discount value' : null,
              ),
              const SizedBox(height: TSizes.spaceBtwInputFields),

              /// Min Amount
              TextFormField(
                controller: controller.minAmount,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Minimum Booking Amount',
                  prefixIcon: Icon(Iconsax.receipt),
                ),
                validator: (v) => v!.isEmpty ? 'Enter minimum amount' : null,
              ),
              const SizedBox(height: TSizes.spaceBtwInputFields),

              /// Max Uses
              TextFormField(
                controller: controller.maxUses,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Max Uses',
                  prefixIcon: Icon(Iconsax.people),
                ),
                validator: (v) => v!.isEmpty ? 'Enter max uses' : null,
              ),
              const SizedBox(height: TSizes.spaceBtwSections),

              /// Expiry Date
              Text('Expiry Date', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: TSizes.spaceBtwItems),
              Obx(() => GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: controller.selectedExpiryDate.value,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    builder: (_, child) => Theme(
                      data: ThemeData.dark(),
                      child: child!,
                    ),
                  );
                  if (picked != null) controller.selectedExpiryDate.value = picked;
                },
                child: Container(
                  padding: const EdgeInsets.all(TSizes.md),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Iconsax.calendar, color: Colors.grey),
                      const SizedBox(width: TSizes.spaceBtwItems),
                      Text(
                        '${controller.selectedExpiryDate.value.day}/${controller.selectedExpiryDate.value.month}/${controller.selectedExpiryDate.value.year}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              )),
              const SizedBox(height: TSizes.spaceBtwSections),

              /// Save Button
              Obx(() => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () => controller.createCoupon(context),
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator()
                      : const Text('Create Coupon'),
                ),
              )),
              const SizedBox(height: TSizes.spaceBtwSections),
            ],
          ),
        ),
      ),
    );
  }
}