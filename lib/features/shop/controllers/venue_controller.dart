import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import '../../../data/repositories/venue/venue_repository.dart';
import '../../../data/services/location/location_service.dart';
import '../../../utils/constants/enums.dart';
import '../../../utils/popups/loaders.dart';
import '../../personalization/controllers/user_controller.dart';
import '../models/sport_model.dart';
import '../models/venue_model.dart';

class VenueController extends GetxController {
  static VenueController get instance => Get.find();

  final _repo = Get.put(VenueRepository());

  final isLoading = false.obs;
  final venue = VenueModel.empty().obs;
  final featuredVenues = <VenueModel>[].obs;
  final allVenues = <VenueModel>[].obs;
  final city = 'Detecting...'.obs;
  final subLocality = ''.obs;
  Position? _userPosition;
  final allSports = <SportModel>[].obs;
  final venueSports = <SportModel>[].obs;


  final locationService = LocationService();

  @override
  void onInit() {
    _fetchLocation();
    fetchFeaturedVenues();
    super.onInit();
  }
  Future<void> fetchLocation() async => _fetchLocation();
  /// Fetch partner's own venue
  Future<void> fetchPartnerVenue(String partnerId) async {
    print('🏢 Fetching partner venue for: $partnerId');
    try {
      isLoading.value = true;
      venue.value = await _repo.fetchPartnerVenue(partnerId);
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    } finally {
      print('🏢 Fetched venue: ${venue.value.id}');
      isLoading.value = false;
    }
  }
  Future<void> _fetchLocation() async {
    try {

      final position = await locationService.getCurrentLocation();
      print('📍 Position: $position');
      if (position != null) {
        _userPosition = position;
        final place = await locationService.getCityFromPosition(position);
        print('📍 Place: $place');
        city.value = place['city']!;
        subLocality.value = place['subLocality']!;
        await fetchAllVenues();
      }
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }
  /// Fetch featured venues
  Future<void> fetchFeaturedVenues() async {
    try {
      isLoading.value = true;
      featuredVenues.assignAll(await _repo.fetchFeaturedVenues());
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAllVenues() async {
    try {
      isLoading.value = true;
      final isAdmin = UserController.instance.user.value.role == AppRole.admin;
      print('🏢 fetchAllVenues — role: ${UserController.instance.user.value.role} isAdmin: $isAdmin');
      final venues = await _repo.fetchAllVenues();
      final filtered = isAdmin ? venues : venues.where((v) => !v.isTesting).toList();
      allVenues.assignAll(filtered);
      if (_userPosition != null) sortByDistance(_userPosition!);
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAllSports() async {
    try {
      final sports = await _repo.fetchAllSports();
      print('🏅 fetchAllSports — found: ${sports.length}');
      for (final s in sports) {
        print('🏅 Sport: ${s.id} — ${s.name}');
      }
      allSports.assignAll(sports);
      print('🏅 allSports count: ${allSports.length}');
    } catch (e) {
      print('🔴 fetchAllSports error: $e');
      TLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    }
  }

  Future<void> fetchVenueSports(List<String> sportIds) async {
    try {
      venueSports.assignAll(await _repo.fetchVenueSports(sportIds));
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    }
  }
  void sortByDistance(Position userPosition) {
    allVenues.sort((a, b) {
      final distA = Geolocator.distanceBetween(userPosition.latitude, userPosition.longitude, a.location.latitude, a.location.longitude);
      final distB = Geolocator.distanceBetween(userPosition.latitude, userPosition.longitude, b.location.latitude, b.location.longitude);
      return distA.compareTo(distB);
    });
  }
  /// Fetch by city
  Future<void> fetchByCity(String city) async {
    print('🏢 Fetching venues for city: $city');
    try {
      isLoading.value = true;
      allVenues.assignAll(await _repo.fetchVenuesByCity(city));

    } catch (e) {
      TLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Toggle venue open/closed
  Future<void> toggleStatus() async {
    try {
      final newStatus = venue.value.status == 'open' ? 'closed' : 'open';
      await _repo.updateVenueStatus(venue.value.id, newStatus);
      venue.value = VenueModel.fromJson({...venue.value.toJson(), 'id': venue.value.id, 'status': newStatus});
      TLoaders.successSnackBar(title: 'Updated', message: 'Venue is now $newStatus');
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    }
  }
}