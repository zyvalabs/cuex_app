import 'package:cuex_app/features/shop/controllers/venue_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/helpers/network_manager.dart';
import '../../../../utils/popups/loaders.dart';
import '../../../data/repositories/coupon/coupon_repository.dart';
import '../models/coupons_model.dart';


class CouponsController extends GetxController {
  static CouponsController get instance => Get.find();

  final _repo = Get.put(CouponsRepository());
  final isLoading = false.obs;
  final isValidating = false.obs;
  final coupons = <CouponsModel>[].obs;
  final appliedCoupon = Rxn<CouponsModel>();
  final discountAmount = 0.0.obs;

  // Form
  final couponCode = TextEditingController();
  final discountValue = TextEditingController();
  final minAmount = TextEditingController();
  final maxUses = TextEditingController();
  final selectedDiscountType = 'flat'.obs;
  final selectedExpiryDate = DateTime.now().add(const Duration(days: 30)).obs;
  final addCouponFormKey = GlobalKey<FormState>();

  /// Fetch venue coupons (partner)
  Future<void> fetchVenueCoupons() async {
    try {
      isLoading.value = true;
      final venueId = VenueController.instance.venue.value.id;
      coupons.assignAll(await _repo.fetchVenueCoupons(venueId));
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Validate and apply coupon (player)
  Future<void> validateAndApplyCoupon(String code, double totalAmount) async {
    try {
      if (code.trim().isEmpty) {
        TLoaders.warningSnackBar(title: 'Enter Code', message: 'Please enter a coupon code');
        return;
      }

      isValidating.value = true;
      final venueId = VenueController.instance.venue.value.id;
      final coupon = await _repo.validateCoupon(code.trim(), venueId);

      if (coupon == null) {
        TLoaders.errorSnackBar(title: 'Invalid', message: 'Coupon not found or inactive');
        return;
      }

      if (!coupon.isValid) {
        TLoaders.errorSnackBar(title: 'Expired', message: 'This coupon has expired or reached its usage limit');
        return;
      }

      if (totalAmount < coupon.minAmount) {
        TLoaders.warningSnackBar(title: 'Min Amount', message: 'Minimum booking amount of ₹${coupon.minAmount.toInt()} required');
        return;
      }

      appliedCoupon.value = coupon;
      _calculateDiscount(coupon, totalAmount);
      TLoaders.successSnackBar(title: 'Applied!', message: 'Coupon applied successfully');
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    } finally {
      isValidating.value = false;
    }
  }

  void _calculateDiscount(CouponsModel coupon, double totalAmount) {
    if (coupon.discountType == 'percentage') {
      discountAmount.value = (totalAmount * coupon.discountValue / 100);
    } else {
      discountAmount.value = coupon.discountValue;
    }
  }

  void removeCoupon() {
    appliedCoupon.value = null;
    discountAmount.value = 0.0;
    couponCode.clear();
  }

  double getFinalAmount(double totalAmount) => (totalAmount - discountAmount.value).clamp(0.0, totalAmount);

  /// Create coupon (partner)
  Future<void> createCoupon(BuildContext context) async {
    try {
      if (!addCouponFormKey.currentState!.validate()) return;

      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TLoaders.customToast(message: 'No Internet Connection');
        return;
      }

      isLoading.value = true;
      final venueId = VenueController.instance.venue.value.id;

      final coupon = CouponsModel(
        id: '',
        venueId: venueId,
        code: couponCode.text.trim().toUpperCase(),
        discountType: selectedDiscountType.value,
        discountValue: double.parse(discountValue.text.trim()),
        minAmount: double.parse(minAmount.text.trim()),
        maxUses: int.parse(maxUses.text.trim()),
        usedCount: 0,
        applicableSlotIds: [],
        expiryDate: selectedExpiryDate.value,
        isActive: true,
        createdAt: DateTime.now(),
      );

      await _repo.createCoupon(coupon);
      await fetchVenueCoupons();
      isLoading.value = false;
      TLoaders.successSnackBar(title: 'Success', message: 'Coupon created successfully');
      if (context.mounted) Navigator.of(context).pop();
    } catch (e) {
      isLoading.value = false;
      TLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    }
  }

  /// Toggle coupon status (partner)
  Future<void> toggleStatus(CouponsModel coupon) async {
    try {
      await _repo.toggleCouponStatus(coupon.id, !coupon.isActive);
      await fetchVenueCoupons();
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    }
  }

  /// Delete coupon (partner)
  Future<void> deleteCoupon(String couponId) async {
    try {
      await _repo.deleteCoupon(couponId);
      await fetchVenueCoupons();
      TLoaders.successSnackBar(title: 'Deleted', message: 'Coupon deleted successfully');
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    }
  }

  /// Increment used count after booking confirmed
  Future<void> incrementUsedCount() async {
    if (appliedCoupon.value != null) {
      await _repo.incrementUsedCount(appliedCoupon.value!.id);
    }
  }

  @override
  void onClose() {
    couponCode.dispose();
    discountValue.dispose();
    minAmount.dispose();
    maxUses.dispose();
    super.onClose();
  }
}