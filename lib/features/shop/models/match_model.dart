import 'package:cloud_firestore/cloud_firestore.dart';

class MatchModel {
  String id;
  String eventId;
  String? player1Id;
  String? player2Id;
  String? team1Id;
  String? team2Id;
  DateTime scheduledTime;
  DateTime? startedAt;
  DateTime? completedAt;
  String? winnerId;
  String matchStatus;
  int totalFrames;
  bool liveStreamingEnabled;
  String? streamKey;
  String? rtmpUrl;
  String? broadcastId;
  String? streamId;
  String? youtubeLink;
  String? posterImageUrl;
  String? streamingPlatform;
  bool isStreaming;
  DateTime? createdAt;
  DateTime? updatedAt;
  bool isFeatured;
  int player1FramesWon;
  int player2FramesWon;
  String? roundName;
  int player1CurrentPoints;
  int player2CurrentPoints;
  String? venueId;
  String? sportId;
  String matchType;
  String? player1Name;
  String? player2Name;
  String? createdBy;
  bool isTesting;

  MatchModel({
    required this.id,
    required this.eventId,
    this.player1Id,
    this.player2Id,
    this.team1Id,
    this.team2Id,
    required this.scheduledTime,
    this.startedAt,
    this.completedAt,
    this.winnerId,
    required this.matchStatus,
    required this.totalFrames,
    this.liveStreamingEnabled = false,
    this.streamKey,
    this.rtmpUrl,
    this.broadcastId,
    this.streamId,
    this.youtubeLink,
    this.posterImageUrl,
    this.streamingPlatform,
    this.isStreaming = false,
    this.createdAt,
    this.updatedAt,
    this.isFeatured = false,
    this.player1FramesWon = 0,
    this.player2FramesWon = 0,
    this.roundName,
    this.player1CurrentPoints = 0,
    this.player2CurrentPoints = 0,
    this.venueId,
    this.sportId,
    this.matchType = 'tournament',
    this.player1Name,
    this.player2Name,
    this.createdBy,
    this.isTesting = false,
  });

  static MatchModel empty() => MatchModel(
    id: '',
    eventId: '',
    scheduledTime: DateTime.now(),
    matchStatus: 'upcoming',
    totalFrames: 0,
    player1FramesWon: 0,
    player2FramesWon: 0,
    roundName: '',
    player1CurrentPoints: 0,
    player2CurrentPoints: 0,
    venueId: '',
    sportId: '',
    matchType: 'tournament',
  );

  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'player1Id': player1Id,
      'player2Id': player2Id,
      'team1Id': team1Id,
      'team2Id': team2Id,
      'scheduledTime': Timestamp.fromDate(scheduledTime),
      'startedAt': startedAt != null ? Timestamp.fromDate(startedAt!) : null,
      'completedAt':
      completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'winnerId': winnerId,
      'roundName': roundName,
      'matchStatus': matchStatus,
      'totalFrames': totalFrames,
      'liveStreamingEnabled': liveStreamingEnabled,
      'streamKey': streamKey,
      'rtmpUrl': rtmpUrl,
      'broadcastId': broadcastId,
      'streamId': streamId,
      'youtubeLink': youtubeLink,
      'posterImageUrl': posterImageUrl,
      'streamingPlatform': streamingPlatform,
      'player1FramesWon': player1FramesWon,
      'player2FramesWon': player2FramesWon,
      'isStreaming': isStreaming,
      'isFeatured': isFeatured,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'player1CurrentPoints': player1CurrentPoints,
      'player2CurrentPoints': player2CurrentPoints,
      'venueId': venueId,
      'sportId': sportId,
      'matchType': matchType,
      'createdBy': createdBy,
      'isTesting': isTesting, // ✅
      if (player1Name != null) 'player1Name': player1Name,
      if (player2Name != null) 'player2Name': player2Name,
    };
  }

  factory MatchModel.fromDocSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return _fromMap(doc.id, data);
  }

  factory MatchModel.fromQuerySnapshot(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return _fromMap(doc.id, data);
  }

  static MatchModel _fromMap(String id, Map<String, dynamic> data) {
    return MatchModel(
      id: id,
      eventId: data['eventId'] ?? '',
      player1Id: data['player1Id'],
      player2Id: data['player2Id'],
      team1Id: data['team1Id'],
      team2Id: data['team2Id'],
      scheduledTime: (data['scheduledTime'] as Timestamp).toDate(),
      startedAt: data['startedAt'] != null
          ? (data['startedAt'] as Timestamp).toDate()
          : null,
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
      winnerId: data['winnerId'],
      matchStatus: data['matchStatus'] ?? 'upcoming',
      totalFrames: data['totalFrames'] ?? 0,
      liveStreamingEnabled: data['liveStreamingEnabled'] ?? false,
      streamKey: data['streamKey'],
      rtmpUrl: data['rtmpUrl'],
      broadcastId: data['broadcastId'],
      streamId: data['streamId'],
      youtubeLink: data['youtubeLink'],
      posterImageUrl: data['posterImageUrl'],
      streamingPlatform: data['streamingPlatform'],
      isStreaming: data['isStreaming'] ?? false,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      isFeatured: data['isFeatured'] ?? false,
      player1FramesWon: data['player1FramesWon'] ?? 0,
      player2FramesWon: data['player2FramesWon'] ?? 0,
      roundName: data['roundName'],
      player1CurrentPoints: data['player1CurrentPoints'] ?? 0,
      player2CurrentPoints: data['player2CurrentPoints'] ?? 0,
      venueId: data['venueId'],
      sportId: data['sportId'],
      matchType: data['matchType'] ?? 'tournament',
      player1Name: data['player1Name'],
      player2Name: data['player2Name'],
      createdBy: data['createdBy'], // ✅
      isTesting: data['isTesting'] ?? false, // ✅
    );
  }

  MatchModel copyWith({
    String? player1Id,
    String? player2Id,
    String? roundName,
    int? totalFrames,
    DateTime? scheduledTime,
    bool? liveStreamingEnabled,
    String? streamKey,
    String? rtmpUrl,
    String? broadcastId,
    String? youtubeLink,
    DateTime? updatedAt,
    String? matchType,
    String? player1Name,
    String? player2Name,
    String? sportId,
    String? venueId,
    String? createdBy,
    bool? isTesting, // ✅
  }) {
    return MatchModel(
      id: id,
      eventId: eventId,
      player1Id: player1Id ?? this.player1Id,
      player2Id: player2Id ?? this.player2Id,
      roundName: roundName ?? this.roundName,
      totalFrames: totalFrames ?? this.totalFrames,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      matchStatus: matchStatus,
      player1FramesWon: player1FramesWon,
      player2FramesWon: player2FramesWon,
      player1CurrentPoints: player1CurrentPoints,
      player2CurrentPoints: player2CurrentPoints,
      liveStreamingEnabled:
      liveStreamingEnabled ?? this.liveStreamingEnabled,
      isStreaming: isStreaming,
      streamKey: streamKey ?? this.streamKey,
      rtmpUrl: rtmpUrl ?? this.rtmpUrl,
      broadcastId: broadcastId ?? this.broadcastId,
      youtubeLink: youtubeLink ?? this.youtubeLink,
      posterImageUrl: posterImageUrl,
      streamingPlatform: streamingPlatform,
      winnerId: winnerId,
      startedAt: startedAt,
      completedAt: completedAt,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFeatured: isFeatured,
      venueId: venueId ?? this.venueId,
      sportId: sportId ?? this.sportId,
      matchType: matchType ?? this.matchType,
      player1Name: player1Name ?? this.player1Name,
      player2Name: player2Name ?? this.player2Name,
      createdBy: createdBy ?? this.createdBy,
      isTesting: isTesting ?? this.isTesting, // ✅
    );
  }
}