import 'package:cloud_firestore/cloud_firestore.dart';

/// Final assembled match data — written once to Firestore's existing
/// `Matches` collection when the user taps "Go Live".
/// Shape matches what the overlay (OverlayTemplate2) already expects to read.
class MatchModel {
  final String? id; // Firestore doc id — null until saved
  final String sport; // e.g. 'Snooker', 'Pool', 'Heyball', 'Billiards'
  final String matchType; // 'Solo' | 'Singles' | 'Doubles'
  final String format; // reds count ('15'/'10'/'6'), '8-ball'/'9-ball', or race-to value
  final int bestOfFrames; // or race-to-points value depending on sport
  final String mode; // 'Practice' or event name — defaults to 'Practice'
  final List<String> playerNames;

  final String streamPlatform; // 'YouTube' | 'RTMP'

  // -- YouTube-specific fields (null if streaming via RTMP instead) --
  final String? youtubeTitle;
  final String? youtubeDescription;
  final String? youtubeThumbnailUrl;
  final String? youtubeVisibility; // 'Public' | 'Unlisted' | 'Private'
  final DateTime? youtubeScheduledStartTime; // null = started immediately
  final String? youtubeBroadcastId;

  // -- Shared stream ingest info (used by both YouTube and RTMP) --
  final String? rtmpUrl;
  final String? streamKey;

  final String createdBy; // userId of whoever created the match
  final DateTime createdAt;

  // -- Event linkage (null for standalone practice matches) --
  final String? eventId;
  final String? roundName; // e.g. "Round of 16", "Quarterfinal", "Final"

  // -- Optional team names, shown alongside player names on each side --
  final String? teamNameA;
  final String? teamNameB;

  const MatchModel({
    this.id,
    required this.sport,
    required this.matchType,
    required this.format,
    required this.bestOfFrames,
    this.mode = 'Practice',
    required this.playerNames,
    required this.streamPlatform,
    this.youtubeTitle,
    this.youtubeDescription,
    this.youtubeThumbnailUrl,
    this.youtubeVisibility,
    this.youtubeScheduledStartTime,
    this.youtubeBroadcastId,
    this.rtmpUrl,
    this.streamKey,
    required this.createdBy,
    required this.createdAt,
    this.eventId,
    this.roundName,
    this.teamNameA,
    this.teamNameB,
  });

  /// Converts this model into a Firestore-writable map.
  Map<String, dynamic> toJson() => {
    'sport': sport,
    'matchType': matchType,
    'format': format,
    'bestOfFrames': bestOfFrames,
    'mode': mode,
    'playerNames': playerNames,
    'streamPlatform': streamPlatform,
    'youtubeTitle': youtubeTitle,
    'youtubeDescription': youtubeDescription,
    'youtubeThumbnailUrl': youtubeThumbnailUrl,
    'youtubeVisibility': youtubeVisibility,
    'youtubeScheduledStartTime': youtubeScheduledStartTime != null
        ? Timestamp.fromDate(youtubeScheduledStartTime!)
        : null,
    'youtubeBroadcastId': youtubeBroadcastId,
    'rtmpUrl': rtmpUrl,
    'streamKey': streamKey,
    'createdBy': createdBy,
    'createdAt': Timestamp.fromDate(createdAt),
    'eventId': eventId,
    'roundName': roundName,
    'teamNameA': teamNameA,
    'teamNameB': teamNameB,
  };

  /// Builds a MatchModel back from a Firestore document — useful later
  /// if you ever need to reopen/edit a match after creation.
  factory MatchModel.fromJson(Map<String, dynamic> data, {String? id}) {
    return MatchModel(
      id: id,
      sport: data['sport'] ?? '',
      matchType: data['matchType'] ?? '',
      format: data['format'] ?? '',
      bestOfFrames: data['bestOfFrames'] ?? 0,
      mode: data['mode'] ?? 'Practice',
      playerNames: List<String>.from(data['playerNames'] ?? []),
      streamPlatform: data['streamPlatform'] ?? '',
      youtubeTitle: data['youtubeTitle'],
      youtubeDescription: data['youtubeDescription'],
      youtubeThumbnailUrl: data['youtubeThumbnailUrl'],
      youtubeVisibility: data['youtubeVisibility'],
      youtubeScheduledStartTime: data['youtubeScheduledStartTime'] != null
          ? (data['youtubeScheduledStartTime'] as Timestamp).toDate()
          : null,
      youtubeBroadcastId: data['youtubeBroadcastId'],
      rtmpUrl: data['rtmpUrl'],
      streamKey: data['streamKey'],
      createdBy: data['createdBy'] ?? '',
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      eventId: data['eventId'],
      roundName: data['roundName'],
      teamNameA: data['teamNameA'],
      teamNameB: data['teamNameB'],
    );
  }
}