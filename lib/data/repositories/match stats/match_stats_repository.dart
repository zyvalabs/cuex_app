import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import '../../../features/shop/models/match_stats_model.dart';

class MatchStatsRepository extends GetxController {
  static MatchStatsRepository get instance => Get.find();

  final _db = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://cuex-ab44c-default-rtdb.asia-southeast1.firebasedatabase.app',
  ).ref();

  /// Update/Create frame
  Future<void> updateItem(MatchStatsModel frame) async {
    try {
      await _db
          .child('match_stats')
          .child(frame.matchId)
          .child('frame_${frame.frameNumber}')
          .set(frame.toJson());
    } catch (e) {
      throw 'Failed to update frame: $e';
    }
  }

  /// Update single field
  Future<void> updateSingleField(String matchId, int frameNumber, Map<String, dynamic> updates) async {
    try {
      await _db
          .child('match_stats')
          .child(matchId)
          .child('frame_$frameNumber')
          .update(updates);
    } catch (e) {
      throw 'Failed to update field: $e';
    }
  }

  /// Add new frame
  Future<void> addItem(MatchStatsModel frame) async {
    try {
      await _db
          .child('match_stats')
          .child(frame.matchId)
          .child('frame_${frame.frameNumber}')
          .set(frame.toJson());
    } catch (e) {
      throw 'Failed to add frame: $e';
    }
  }

  /// Delete frame
  Future<void> deleteItem(MatchStatsModel frame) async {
    try {
      await _db
          .child('match_stats')
          .child(frame.matchId)
          .child('frame_${frame.frameNumber}')
          .remove();
    } catch (e) {
      throw 'Failed to delete frame: $e';
    }
  }

  /// Get single frame
  Future<MatchStatsModel?> fetchSingleItem(String matchId, int frameNumber) async {
    try {
      final snapshot = await _db
          .child('match_stats')
          .child(matchId)
          .child('frame_$frameNumber')
          .get();

      if (!snapshot.exists) return null;

      final data = Map<String, dynamic>.from(snapshot.value as Map);
      return MatchStatsModel.fromRealtimeDB(data, frameNumber, matchId);
    } catch (e) {
      throw 'Failed to get frame: $e';
    }
  }

  /// Fetch all frames for a specific match
  Future<List<MatchStatsModel>> fetchFramesByMatch(String matchId) async {
    try {
      final snapshot = await _db
          .child('match_stats')
          .child(matchId)
          .get();

      if (!snapshot.exists) return [];

      final frames = <MatchStatsModel>[];
      final data = Map<String, dynamic>.from(snapshot.value as Map);

      data.forEach((key, value) {
        if (key.startsWith('frame_')) {
          final frameNumber = int.parse(key.replaceFirst('frame_', ''));
          final frameData = Map<String, dynamic>.from(value as Map);
          frames.add(MatchStatsModel.fromRealtimeDB(frameData, frameNumber, matchId));
        }
      });

      frames.sort((a, b) => a.frameNumber.compareTo(b.frameNumber));
      return frames;
    } catch (e) {
      throw 'Failed to fetch frames: $e';
    }
  }

  /// Fetch current/active frame (no winnerId)
  Future<MatchStatsModel?> getCurrentFrame(String matchId) async {
    try {
      final frames = await fetchFramesByMatch(matchId);
      return frames.where((f) => f.winnerId == null).lastOrNull;
    } catch (e) {
      throw 'Failed to get current frame: $e';
    }
  }

  /// Fetch completed frames only
  Future<List<MatchStatsModel>> getCompletedFrames(String matchId) async {
    try {
      final frames = await fetchFramesByMatch(matchId);
      return frames.where((f) => f.winnerId != null).toList();
    } catch (e) {
      throw 'Failed to get completed frames: $e';
    }
  }

  /// Fetch single frame by match and frame number
  Future<MatchStatsModel?> getFrameByNumber(String matchId, int frameNumber) async {
    try {
      return await fetchSingleItem(matchId, frameNumber);
    } catch (e) {
      throw 'Failed to get frame by number: $e';
    }
  }

  /// Real-time listener for single frame
  Stream<MatchStatsModel?> watchFrame(String matchId, int frameNumber) {
    return _db
        .child('match_stats')
        .child(matchId)
        .child('frame_$frameNumber')
        .onValue
        .map((event) {
      if (!event.snapshot.exists) return null;

      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      return MatchStatsModel.fromRealtimeDB(data, frameNumber, matchId);
    });
  }

  /// Real-time listener for all frames by match
  Stream<List<MatchStatsModel>> watchFramesByMatch(String matchId) {
    print('Repository: Watching frames for matchId: $matchId');

    return _db
        .child('match_stats')
        .child(matchId)
        .onValue
        .map((event) {
      print('Repository: Snapshot received');

      if (!event.snapshot.exists) return <MatchStatsModel>[];

      final frames = <MatchStatsModel>[];
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);

      data.forEach((key, value) {
        if (key.startsWith('frame_')) {
          final frameNumber = int.parse(key.replaceFirst('frame_', ''));
          final frameData = Map<String, dynamic>.from(value as Map);
          frames.add(MatchStatsModel.fromRealtimeDB(frameData, frameNumber, matchId));
          print('Frame loaded: frame_$frameNumber');
        }
      });

      frames.sort((a, b) => a.frameNumber.compareTo(b.frameNumber));
      print('Total frames: ${frames.length}');
      return frames;
    });
  }

  /// Delete all frames for a match
  Future<void> deleteAllFrames(String matchId) async {
    try {
      await _db
          .child('match_stats')
          .child(matchId)
          .remove();
    } catch (e) {
      throw 'Failed to delete all frames: $e';
    }
  }
}