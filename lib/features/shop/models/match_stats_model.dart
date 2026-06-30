import 'package:cloud_firestore/cloud_firestore.dart';

class MatchStatsModel {
  String id;
  String matchId;
  int frameNumber;
  int player1Points;
  int player2Points;
  int player1HighestBreak;
  int player2HighestBreak;
  List<String> player1BallSequence;
  List<String> player2BallSequence;
  String? winnerId;
  DateTime? completedAt;
  DateTime createdAt;

  MatchStatsModel({
    required this.id,
    required this.matchId,
    required this.frameNumber,
    this.player1Points = 0,
    this.player2Points = 0,
    this.player1HighestBreak = 0,
    this.player2HighestBreak = 0,
    this.player1BallSequence = const [],
    this.player2BallSequence = const [],
    this.winnerId,
    this.completedAt,
    required this.createdAt,
  });

  // Empty helper
  static MatchStatsModel empty() => MatchStatsModel(
    id: '',
    matchId: '',
    frameNumber: 0,
    createdAt: DateTime.now(),
  );

  // Convert to JSON - for Realtime Database (no Timestamp)
  Map<String, dynamic> toJson() {
    return {
      'matchId': matchId,
      'frameNumber': frameNumber,
      'player1Points': player1Points,
      'player2Points': player2Points,
      'player1HighestBreak': player1HighestBreak,
      'player2HighestBreak': player2HighestBreak,
      'player1BallSequence': player1BallSequence,
      'player2BallSequence': player2BallSequence,
      'winnerId': winnerId,
      'completedAt': completedAt?.millisecondsSinceEpoch,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  // From Realtime Database
  factory MatchStatsModel.fromRealtimeDB(Map<String, dynamic> data, int frameNumber, String matchId) {
    return MatchStatsModel(
      id: '${matchId}_frame_$frameNumber',
      matchId: matchId,
      frameNumber: frameNumber,
      player1Points: data['player1Points'] ?? 0,
      player2Points: data['player2Points'] ?? 0,
      player1HighestBreak: data['player1HighestBreak'] ?? 0,
      player2HighestBreak: data['player2HighestBreak'] ?? 0,
      player1BallSequence: data['player1BallSequence'] != null
          ? List<String>.from(data['player1BallSequence'])
          : [],
      player2BallSequence: data['player2BallSequence'] != null
          ? List<String>.from(data['player2BallSequence'])
          : [],
      winnerId: data['winnerId'],
      completedAt: data['completedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['completedAt'])
          : null,
      createdAt: data['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['createdAt'])
          : DateTime.now(),
    );
  }

  // From DocumentSnapshot (keep for backwards compatibility)
  factory MatchStatsModel.fromDocSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MatchStatsModel(
      id: doc.id,
      matchId: data['matchId'] ?? '',
      frameNumber: data['frameNumber'] ?? 0,
      player1Points: data['player1Points'] ?? 0,
      player2Points: data['player2Points'] ?? 0,
      player1HighestBreak: data['player1HighestBreak'] ?? 0,
      player2HighestBreak: data['player2HighestBreak'] ?? 0,
      player1BallSequence: List<String>.from(data['player1BallSequence'] ?? []),
      player2BallSequence: List<String>.from(data['player2BallSequence'] ?? []),
      winnerId: data['winnerId'],
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  // From QuerySnapshot (keep for backwards compatibility)
  factory MatchStatsModel.fromQuerySnapshot(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MatchStatsModel(
      id: doc.id,
      matchId: data['matchId'] ?? '',
      frameNumber: data['frameNumber'] ?? 0,
      player1Points: data['player1Points'] ?? 0,
      player2Points: data['player2Points'] ?? 0,
      player1HighestBreak: data['player1HighestBreak'] ?? 0,
      player2HighestBreak: data['player2HighestBreak'] ?? 0,
      player1BallSequence: List<String>.from(data['player1BallSequence'] ?? []),
      player2BallSequence: List<String>.from(data['player2BallSequence'] ?? []),
      winnerId: data['winnerId'],
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}