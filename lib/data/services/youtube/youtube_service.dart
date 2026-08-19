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
          // liveStreamingEnabled is NOT set here — we only find out for real
          // when the user actually attempts to create a broadcast (see below).
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
      // Gap #5 fix: if silent refresh fails mid-flow, surface a clear
      // reconnect message instead of letting a raw exception bubble up.
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

  /// Gap #4 fix: read the last-known live-streaming-enabled status from
  /// Firestore, so the UI doesn't need to re-attempt an API call just to
  /// know the channel's status on every screen load.
  /// Returns null if we've never actually attempted a broadcast yet
  /// (i.e. status is unknown).
  Future<bool?> getLiveStreamingEnabledStatus(String userId) async {
    final doc = await _firestore.collection('Users').doc(userId).get();
    return doc.data()?['youtube']?['liveStreamingEnabled'];
  }

  // ==============================
  // Internal — fetch channel from API
  // ==============================

  Future<Map<String, String>> _fetchChannelInfo(String token) async {
    final response = await http.get(
      Uri.parse('https://www.googleapis.com/youtube/v3/channels?part=snippet&mine=true'),
      headers: {'Authorization': 'Bearer $token'},
    );

    _checkForApiErrors(response); // Gap #1/#2/#3 fix — shared error checker

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
  //
  // This is the ONLY point where we can genuinely learn whether the
  // channel is verified/live-streaming-enabled — YouTube doesn't expose
  // a standalone "check status" endpoint, so the attempt IS the check.
  //
  // categoryId, privacyStatus, and scheduledStartTime are now parameters
  // instead of hardcoded (Gap #6 fix), so the UI's visibility selector /
  // schedule picker / category can actually drive this call.

  Future<Map<String, String>> createLiveBroadcast({
    required String userId,
    required String title,
    required String description,
    required List<String> tags,
    String privacyStatus = 'public', // 'public' | 'unlisted' | 'private'
    String categoryId = '17', // 17 = Sports
    DateTime? scheduledStartTime, // null = start ~1 min from now
  }) async {
    final token = await getAccessToken();

    try {
      final broadcastResponse = await http.post(
        Uri.parse('https://www.googleapis.com/youtube/v3/liveBroadcasts?part=snippet,status,contentDetails'),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        body: jsonEncode({
          'snippet': {
            'title': title,
            'description': description,
            'tags': tags,
            'categoryId': categoryId,
            'scheduledStartTime': (scheduledStartTime ?? DateTime.now().add(const Duration(minutes: 1)))
                .toUtc()
                .toIso8601String(),
          },
          'status': {
            'privacyStatus': privacyStatus,
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

      // Gap #1/#2/#3 fix: check status code + specific error reasons
      // BEFORE trying to parse the body as a successful broadcast.
      _checkForApiErrors(broadcastResponse);

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

      _checkForApiErrors(streamResponse);

      final stream = jsonDecode(streamResponse.body);
      final streamId = stream['id'];
      final streamKey = stream['cdn']['ingestionInfo']['streamName'];
      final rtmpUrl = stream['cdn']['ingestionInfo']['ingestionAddress'];

      final bindResponse = await http.post(
        Uri.parse('https://www.googleapis.com/youtube/v3/liveBroadcasts/bind?id=$broadcastId&part=id&streamId=$streamId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      _checkForApiErrors(bindResponse);

      dev.log('✅ Broadcast created: $broadcastId embeddable: true');

      // Success — this call working at all confirms the channel IS
      // live-streaming enabled, so persist that for next time (Gap #4 fix).
      await _firestore.collection('Users').doc(userId).update({
        'youtube.liveStreamingEnabled': true,
      });

      return {
        'broadcast_id': broadcastId,
        'stream_key': streamKey,
        'rtmp_url': rtmpUrl,
        'youtube_link': 'https://www.youtube.com/watch?v=$broadcastId',
      };
    } on LiveStreamingNotEnabledException {
      // Persist the negative result too, so the UI can show the
      // verification warning next time without re-attempting the call.
      await _firestore.collection('Users').doc(userId).update({
        'youtube.liveStreamingEnabled': false,
      });
      rethrow;
    }
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
    _checkForApiErrors(response);
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
    _checkForApiErrors(response);
    dev.log('✅ Broadcast stopped: $broadcastId');
  }

  // ==============================
  // Shared error checker (Gaps #1, #2, #3 fix)
  // ==============================
  //
  // Inspects any YouTube API http.Response and throws the correct
  // specific exception based on the error "reason" field, instead of
  // silently continuing to parse a failed response as if it succeeded.
  void _checkForApiErrors(http.Response response) {
    if (response.statusCode < 400) return; // success, nothing to do

    Map<String, dynamic>? errorBody;
    try {
      errorBody = jsonDecode(response.body);
    } catch (_) {
      // body wasn't valid JSON — fall through to generic exception below
    }

    final errors = errorBody?['error']?['errors'] as List?;
    final reason = errors != null && errors.isNotEmpty ? errors[0]['reason'] : null;

    switch (reason) {
      case 'liveStreamingNotEnabled':
        throw LiveStreamingNotEnabledException();
      case 'quotaExceeded':
        throw YouTubeQuotaException();
      default:
        final message = errorBody?['error']?['message'] ?? 'YouTube API request failed (${response.statusCode}).';
        throw YouTubeAuthException(message);
    }
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