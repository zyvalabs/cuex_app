import 'package:get/get.dart';
import '../core/model/match_model.dart';
import '../repositories/match_repository.dart';

/// Fetches matches linked to a specific event — used by EventDetailsScreen.
/// Separate from MyMatchesController since this is scoped to one event,
/// not the current user's entire match history.
class EventMatchesController extends GetxController {
  final MatchRepository _matchRepository = MatchRepository();

  final RxList<MatchModel> matches = <MatchModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxnString error = RxnString();

  Future<void> fetchMatches(String eventId) async {
    isLoading.value = true;
    error.value = null;

    // ignore: avoid_print
    print('🟠 [EventMatchesController] fetchMatches() started for eventId=$eventId');

    try {
      final result = await _matchRepository.getMatchesByEvent(eventId);

      // ignore: avoid_print
      print('🟢 [EventMatchesController] fetched ${result.length} matches');

      matches.value = result;
      isLoading.value = false;
    } catch (e) {
      // ignore: avoid_print
      print('🔴 [EventMatchesController] fetchMatches() FAILED: $e');

      error.value = e.toString();
      isLoading.value = false;
    }
  }
}