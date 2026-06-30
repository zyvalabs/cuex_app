import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as dev;

class YouTubeService {
  final _firestore = FirebaseFirestore.instance;

  final _googleSignIn = GoogleSignIn(
    scopes: [
      'https://www.googleapis.com/auth/youtube',
      'https://www.googleapis.com/auth/youtube.force-ssl',
    ],
  );

  // ==============================
  // Connect — shows native picker
  // ==============================

  Future<void> connectYouTube(String userId) async {
    try {
      await _googleSignIn.signOut(); // force picker to show
      final account = await _googleSignIn.signIn();
      if (account == null) throw YouTubeAuthException('Sign in cancelled.');

      final auth = await account.authentication;
      if (auth.accessToken == null) throw YouTubeAuthException('Failed to get token.');

      // fetch and save channel info to Firestore
      final channelInfo = await _fetchChannelInfo(auth.accessToken!);

      await _firestore.collection('Users').doc(userId).update({
        'youtube': {
          'connected': true,
          'channel_name': channelInfo['name'],
          'channel_image': channelInfo['image'],
        }
      });

      dev.log('✅ YouTube connected: ${channelInfo['name']}');
    } catch (e) {
      dev.log('❌ connectYouTube error: $e');
      rethrow;
    }
  }

  // ==============================
  // Get fresh access token silently
  // ==============================

  Future<String> getAccessToken() async {
    try {
      // try silent sign in first
      var account = await _googleSignIn.signInSilently();

      // if silent fails, try current account
      account ??= _googleSignIn.currentUser;

      if (account == null) {
        throw YouTubeAuthException('YouTube not connected. Please reconnect in settings.');
      }

      final auth = await account.authentication;
      if (auth.accessToken == null) {
        throw YouTubeAuthException('Failed to get access token. Please reconnect.');
      }

      return auth.accessToken!;
    } catch (e) {
      dev.log('❌ getAccessToken error: $e');
      if (e is YouTubeAuthException) rethrow;
      throw YouTubeAuthException('YouTube session lost. Please reconnect in settings.');
    }
  }

  // ==============================
  // Check if connected
  // ==============================

  Future<bool> isConnected(String userId) async {
    final doc = await _firestore.collection('Users').doc(userId).get();
    return doc.data()?['youtube']?['connected'] == true;
  }

  // ==============================
  // Get channel info from Firestore
  // ==============================

  Future<Map<String, String>> getChannelInfo(String userId) async {
    final doc = await _firestore.collection('Users').doc(userId).get();
    final youtube = doc.data()?['youtube'];
    return {
      'name': youtube?['channel_name'] ?? 'Unknown',
      'image': youtube?['channel_image'] ?? '',
    };
  }

  // ==============================
  // Internal — fetch channel from API
  // ==============================

  Future<Map<String, String>> _fetchChannelInfo(String token) async {
    final response = await http.get(
      Uri.parse('https://www.googleapis.com/youtube/v3/channels?part=snippet&mine=true'),
      headers: {'Authorization': 'Bearer $token'},
    );

    final data = jsonDecode(response.body);
    if (data['items'] == null || data['items'].isEmpty) throw YouTubeChannelNotFoundException();

    final channel = data['items'][0];
    return {
      'name': channel['snippet']['title'] ?? 'Unknown',
      'image': channel['snippet']['thumbnails']['default']['url'] ?? '',
    };
  }

  // ==============================
  // Disconnect
  // ==============================

  Future<void> disconnect(String userId) async {
    await _googleSignIn.signOut();
    await _firestore.collection('Users').doc(userId).update({
      'youtube': FieldValue.delete(),
    });
    dev.log('✅ YouTube disconnected');
  }

  // ==============================
  // Create live broadcast
  // ==============================

  Future<Map<String, String>> createLiveBroadcast({
    required String userId,
    required String title,
    required String description,
    required List<String> tags,
  }) async {
    final token = await getAccessToken();

    final broadcastResponse = await http.post(
      Uri.parse('https://www.googleapis.com/youtube/v3/liveBroadcasts?part=snippet,status,contentDetails'),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      body: jsonEncode({
        'snippet': {
          'title': title,
          'description': description,
          'tags': tags,
          'scheduledStartTime': DateTime.now().add(const Duration(minutes: 1)).toUtc().toIso8601String(),
        },
        'status': {
          'privacyStatus': 'public',
          'selfDeclaredMadeForKids': false,
          'embeddable': true,
        },
        'contentDetails': {
          'enableAutoStart': true,
          'enableAutoStop': true,
          'recordFromStart': true,
          'enableEmbed': true,
        },
      }),
    );

    final broadcast = jsonDecode(broadcastResponse.body);
    final broadcastId = broadcast['id'];

    final streamResponse = await http.post(
      Uri.parse('https://www.googleapis.com/youtube/v3/liveStreams?part=snippet,cdn'),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      body: jsonEncode({
        'snippet': {'title': '$title Stream'},
        'cdn': {'frameRate': 'variable', 'ingestionType': 'rtmp', 'resolution': 'variable'},
      }),
    );

    final stream = jsonDecode(streamResponse.body);
    final streamId = stream['id'];
    final streamKey = stream['cdn']['ingestionInfo']['streamName'];
    final rtmpUrl = stream['cdn']['ingestionInfo']['ingestionAddress'];

    await http.post(
      Uri.parse('https://www.googleapis.com/youtube/v3/liveBroadcasts/bind?id=$broadcastId&part=id&streamId=$streamId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    dev.log('✅ Broadcast created: $broadcastId embeddable: true');

    return {
      'broadcast_id': broadcastId,
      'stream_key': streamKey,
      'rtmp_url': rtmpUrl,
      'youtube_link': 'https://www.youtube.com/watch?v=$broadcastId',
    };
  }

  // ==============================
  // Start broadcast
  // ==============================

  Future<void> startBroadcast(String userId, String broadcastId) async {
    final token = await getAccessToken();
    final response = await http.post(
      Uri.parse('https://www.googleapis.com/youtube/v3/liveBroadcasts/transition?broadcastStatus=live&id=$broadcastId&part=status'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode >= 400) throw YouTubeAuthException('Failed to start broadcast.');
    dev.log('✅ Broadcast started: $broadcastId');
  }

  // ==============================
  // Stop broadcast
  // ==============================

  Future<void> stopBroadcast(String userId, String broadcastId) async {
    final token = await getAccessToken();
    final response = await http.post(
      Uri.parse('https://www.googleapis.com/youtube/v3/liveBroadcasts/transition?broadcastStatus=complete&id=$broadcastId&part=status'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode >= 400) throw YouTubeAuthException('Failed to stop broadcast.');
    dev.log('✅ Broadcast stopped: $broadcastId');
  }
}

// ==============================
// Exceptions
// ==============================

class YouTubeAuthException implements Exception {
  final String message;
  YouTubeAuthException(this.message);
  @override
  String toString() => message;
}

class YouTubeQuotaException implements Exception {
  @override
  String toString() => 'YouTube API quota exceeded. Try again tomorrow.';
}

class LiveStreamingNotEnabledException implements Exception {
  @override
  String toString() => 'Live streaming not enabled on this YouTube channel.';
}

class YouTubeChannelNotFoundException implements Exception {
  @override
  String toString() => 'YouTube channel not found.';
}