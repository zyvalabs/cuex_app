import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../features/shop/models/sport_model.dart';
import '../../../features/shop/models/venue_model.dart';
import '../../../features/personalization/controllers/user_controller.dart';
import '../../../utils/constants/enums.dart';
import '../../../utils/exceptions/firebase_exceptions.dart';
import '../../../utils/exceptions/format_exceptions.dart';
import '../../../utils/exceptions/platform_exceptions.dart';

class VenueRepository extends GetxController {
  static VenueRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  bool get _isAdmin {
    try {
      final role = Get.find<UserController>().user.value.role;
      print('🏢 _isAdmin check — role: $role isAdmin: ${role == AppRole.admin}');
      return role == AppRole.admin;
    } catch (e) {
      print('🔴 _isAdmin error: $e');
      return false;
    }
  }

  List<VenueModel> _filterForNonAdmin(List<VenueModel> venues) {
    final filtered = venues.where((v) => !v.isTesting).toList();
    print('🏢 Filter — before: ${venues.length} after: ${filtered.length} isAdmin: $_isAdmin');
    for (final v in venues) {
      print('🏢 Venue: ${v.name} — isActive: ${v.isActive} isTesting: ${v.isTesting} isFeatured: ${v.isFeatured}');
    }
    return filtered;
  }

  /// Add new venue
  Future<String> addVenue(VenueModel venue) async {
    try {
      final doc = await _db.collection('Venues').add(venue.toJson());
      print('🏢 Added venue: ${doc.id}');
      return doc.id;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Fetch single venue by ID
  Future<VenueModel> fetchVenueById(String venueId) async {
    try {
      print('🏢 Fetching venue by ID: $venueId');
      final doc = await _db.collection('Venues').doc(venueId).get();
      final venue = VenueModel.fromDocumentSnapshot(doc);
      print('🏢 Fetched: ${venue.name} isActive: ${venue.isActive} isTesting: ${venue.isTesting}');
      return venue;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Fetch partner's own venue
  Future<VenueModel> fetchPartnerVenue(String partnerId) async {
    try {
      print('🏢 Fetching partner venue for: $partnerId');
      final query = await _db.collection('Venues').where('partnerId', isEqualTo: partnerId).limit(1).get();
      if (query.docs.isEmpty) {
        print('🏢 No venue found for partner: $partnerId');
        return VenueModel.empty();
      }
      final venue = VenueModel.fromQueryDocumentSnapshot(query.docs.first);
      print('🏢 Partner venue: ${venue.name} isActive: ${venue.isActive} isTesting: ${venue.isTesting}');
      return venue;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Fetch all venues
  Future<List<VenueModel>> fetchAllVenues() async {
    try {
      print('🏢 fetchAllVenues — isAdmin: $_isAdmin');
      final query = await _db.collection('Venues').get();
      print('🏢 Raw venues from Firestore: ${query.docs.length}');
      final venues = query.docs.map((doc) {
        final v = VenueModel.fromQueryDocumentSnapshot(doc);
        print('🏢 Doc: ${v.name} isActive: ${v.isActive} isTesting: ${v.isTesting}');
        return v;
      }).toList();
      return _isAdmin ? venues : _filterForNonAdmin(venues);
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      print('🔴 fetchAllVenues error: $e');
      throw 'Something went wrong. Please try again';
    }
  }

  /// Fetch active venues only
  Future<List<VenueModel>> fetchActiveVenues() async {
    try {
      print('🏢 fetchActiveVenues');
      final query = await _db.collection('Venues').where('isActive', isEqualTo: true).get();
      final venues = query.docs.map((doc) => VenueModel.fromQueryDocumentSnapshot(doc)).toList();
      print('🏢 Active venues: ${venues.length}');
      return _isAdmin ? venues : _filterForNonAdmin(venues);
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      print('🔴 fetchActiveVenues error: $e');
      throw 'Something went wrong. Please try again';
    }
  }

  /// Fetch venues by city
  Future<List<VenueModel>> fetchVenuesByCity(String city) async {
    try {
      print('🏢 fetchVenuesByCity: $city');
      final query = await _db.collection('Venues').where('city', isEqualTo: city).where('isActive', isEqualTo: true).get();
      final venues = query.docs.map((doc) => VenueModel.fromQueryDocumentSnapshot(doc)).toList();
      print('🏢 Venues in $city: ${venues.length}');
      return _isAdmin ? venues : _filterForNonAdmin(venues);
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      print('🔴 fetchVenuesByCity error: $e');
      throw 'Something went wrong. Please try again';
    }
  }

  /// Fetch featured venues
  Future<List<VenueModel>> fetchFeaturedVenues() async {
    try {
      print('🏢 fetchFeaturedVenues');
      final query = await _db.collection('Venues').where('isFeatured', isEqualTo: true).where('isActive', isEqualTo: true).get();
      final venues = query.docs.map((doc) => VenueModel.fromQueryDocumentSnapshot(doc)).toList();
      print('🏢 Featured venues: ${venues.length}');
      return _isAdmin ? venues : _filterForNonAdmin(venues);
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      print('🔴 fetchFeaturedVenues error: $e');
      throw 'Something went wrong. Please try again';
    }
  }

  /// Fetch open venues
  Future<List<VenueModel>> fetchOpenVenues() async {
    try {
      final query = await _db.collection('Venues').where('status', isEqualTo: 'open').where('isActive', isEqualTo: true).get();
      final venues = query.docs.map((doc) => VenueModel.fromQueryDocumentSnapshot(doc)).toList();
      return _isAdmin ? venues : _filterForNonAdmin(venues);
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Update full venue
  Future<void> updateVenue(VenueModel venue) async {
    try {
      await _db.collection('Venues').doc(venue.id).update(venue.toJson());
      print('🏢 Updated venue: ${venue.id}');
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Update venue status (open/closed)
  Future<void> updateVenueStatus(String venueId, String status) async {
    try {
      await _db.collection('Venues').doc(venueId).update({'status': status});
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Toggle featured
  Future<void> toggleFeatured(String venueId, bool isFeatured) async {
    try {
      await _db.collection('Venues').doc(venueId).update({'isFeatured': isFeatured});
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Toggle active/inactive (admin)
  Future<void> toggleActive(String venueId, bool isActive) async {
    try {
      await _db.collection('Venues').doc(venueId).update({'isActive': isActive});
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Toggle streaming enabled (admin)
  Future<void> toggleStreaming(String venueId, bool streamingEnabled) async {
    try {
      await _db.collection('Venues').doc(venueId).update({'streamingEnabled': streamingEnabled});
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Delete venue
  Future<void> deleteVenue(String venueId) async {
    try {
      await _db.collection('Venues').doc(venueId).delete();
      print('🏢 Deleted venue: $venueId');
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Update tables count
  Future<void> updateTablesCount(String venueId, int count) async {
    try {
      await _db.collection('Venues').doc(venueId).update({'tablesCount': count});
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Fetch all sports
  Future<List<SportModel>> fetchAllSports() async {
    try {
      final query = await _db.collection('Sports').where('isActive', isEqualTo: true).get();
      return query.docs.map((doc) => SportModel.fromQueryDocumentSnapshot(doc)).toList();
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Fetch venue sports by ids
  Future<List<SportModel>> fetchVenueSports(List<String> sportIds) async {
    try {
      if (sportIds.isEmpty) return [];
      final query = await _db.collection('Sports').where(FieldPath.documentId, whereIn: sportIds).get();
      return query.docs.map((doc) => SportModel.fromQueryDocumentSnapshot(doc)).toList();
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }
}