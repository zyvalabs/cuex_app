import 'package:get/get.dart';

import '../../../data/repositories/streaming credit/streaming_credit_repository.dart';

import '../../../utils/popups/loaders.dart';
import '../models/streaming_credit_model.dart';


class StreamingCreditsController extends GetxController {
  static StreamingCreditsController get instance => Get.find();

  final _repo = Get.put(StreamingCreditsRepository());

  final isLoading = false.obs;
  final credits = Rxn<StreamingCreditsModel>();

  /// Fetch and observe credits for a venue or user
  Future<void> fetchCredits(String id) async {
    try {
      isLoading.value = true;
      credits.value = await _repo.fetchCredits(id);
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Check if has credits — used before match creation
  Future<bool> hasCredits(String id) async {
    try {
      return await _repo.hasCredits(id);
    } catch (e) {
      return false;
    }
  }

  /// Purchase credits — admin adds after payment received
  Future<void> purchaseCredits({
    required String id,
    required int creditCount,
    required double amount,
    required String paymentRef,
    String? note,
  }) async {
    try {
      isLoading.value = true;
      await _repo.addCredits(
        id: id,
        credits: creditCount,
        amount: amount,
        paymentRef: paymentRef,
        note: note,
      );
      // Refresh after purchase
      await fetchCredits(id);
      TLoaders.successSnackBar(title: 'Credits Added', message: '$creditCount streaming credits added successfully');
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Consume 1 credit when match goes live
  /// Returns true if credit deducted successfully, false if no credits
  Future<bool> consumeCredit(String id) async {
    try {
      final success = await _repo.deductCredit(id);
      if (!success) {
        TLoaders.warningSnackBar(
          title: 'No Credits',
          message: 'No streaming credits remaining. Please purchase more to go live.',
        );
        return false;
      }
      // Refresh credits after deduction
      await fetchCredits(id);
      return true;
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
      return false;
    }
  }

  /// Refund credit if match cancelled after going live
  Future<void> refundCredit(String id) async {
    try {
      await _repo.refundCredit(id);
      await fetchCredits(id);
      TLoaders.successSnackBar(title: 'Refunded', message: '1 streaming credit refunded');
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  /// Admin manually set credits
  Future<void> adminSetCredits({
    required String id,
    required int totalCredits,
    required int usedCredits,
  }) async {
    try {
      isLoading.value = true;
      await _repo.setCredits(
        id: id,
        totalCredits: totalCredits,
        usedCredits: usedCredits,
      );
      await fetchCredits(id);
      TLoaders.successSnackBar(title: 'Updated', message: 'Credits updated successfully');
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Remaining credits count — shortcut getter
  int get remainingCredits => credits.value?.remainingCredits ?? 0;

  /// Has any credits remaining
  bool get hasRemainingCredits => remainingCredits > 0;
}