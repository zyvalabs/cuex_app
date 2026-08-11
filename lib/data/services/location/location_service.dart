import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';


class LocationService {
  // ─────────────────────────────────────────
  // Get current position — production ready
  // ─────────────────────────────────────────
  Future<Position?> getCurrentLocation() async {
    try {
      // 1. Check if GPS is enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('📍 Location services disabled');
        return null;
      }

      // 2. Check existing permission
      LocationPermission permission = await Geolocator.checkPermission();

      // 3. Denied forever — can't ask again
      if (permission == LocationPermission.deniedForever) {
        print('📍 Permission denied forever');
        return null;
      }

      // 4. Not yet asked or denied — request
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          print('📍 Permission denied after request');
          return null;
        }
      }

      // 5. Get position — medium accuracy is faster
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
      print('📍 Position: $position');
      return position;
    } catch (e) {
      print('📍 getCurrentLocation error: $e');
      return null;
    }
  }

  // ─────────────────────────────────────────
  // Get city + sublocality from position
  // ─────────────────────────────────────────
  Future<Map<String, String>> getCityFromPosition(Position position) async {
    try {
      final geocoding = Geocoding();
      final placemarks = await geocoding.placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isEmpty) {
        return {'city': 'Set Location', 'subLocality': ''};
      }

      final place = placemarks.first;
      final city = place.locality ?? place.administrativeArea ?? 'Set Location';
      final subLocality = place.subLocality ?? '';

      print('📍 City: $city subLocality: $subLocality');
      return {'city': city, 'subLocality': subLocality};
    } catch (e) {
      print('📍 getCityFromPosition error: $e');
      return {'city': 'Set Location', 'subLocality': ''};
    }
  }

  // ─────────────────────────────────────────
  // Open device location settings
  // ─────────────────────────────────────────
  Future<void> openSettings() async {
    await Geolocator.openLocationSettings();
  }

  // ─────────────────────────────────────────
  // Open app permission settings
  // ─────────────────────────────────────────
  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }
}