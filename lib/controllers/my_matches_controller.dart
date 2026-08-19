import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/model/match_model.dart';
import '../repositories/match_repository.dart';

/// Controller for the My Matches screen — fetches the current user's
/// created matches, newest first. Separate from MatchCreationController
/// since browsing/listing is a different concern from the creation wizard.
class MyMatchesController extends GetxController {
  final MatchRepository _matchRepository = MatchRepository();

  final RxList<MatchModel> matches = <MatchModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxnString error = RxnString();

  String get _userId => FirebaseAuth.instance.currentUser!.uid;

  @override
  void onInit() {
    super.onInit();
    fetchMatches();
  }

  Future<void> fetchMatches() async {
    isLoading.value = true;
    error.value = null;

    // ignore: avoid_print
    print('🟠 [MyMatchesController] fetchMatches() started for userId=$_userId');

    try {
      final result = await _matchRepository.getUserMatches(_userId);

      // ignore: avoid_print
      print('🟢 [MyMatchesController] fetched ${result.length} matches');

      matches.value = result;
      isLoading.value = false;
    } catch (e) {
      // ignore: avoid_print
      print('🔴 [MyMatchesController] fetchMatches() FAILED: $e');

      error.value = e.toString();
      isLoading.value = false;
    }
  }

  /// Deletes a match and removes it from the local list immediately
  /// (no need to re-fetch the whole list from Firestore).
  Future<bool> deleteMatch(String matchId) async {
    // ignore: avoid_print
    print('🟠 [MyMatchesController] deleteMatch() called for id=$matchId');

    try {
      await _matchRepository.deleteMatch(matchId);
      matches.removeWhere((m) => m.id == matchId);

      // ignore: avoid_print
      print('🟢 [MyMatchesController] deleteMatch() succeeded, list updated');

      return true;
    } catch (e) {
      // ignore: avoid_print
      print('🔴 [MyMatchesController] deleteMatch() FAILED: $e');

      return false;
    }
  }
}