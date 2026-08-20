import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/utils/constants/app_colors.dart';
import '../../data/services/youtube/youtube_service.dart';
import '../../widgets/common/custom_app_bar.dart';


/// Stream Settings screen — connect/disconnect YouTube account.
/// Reads/writes the same Firestore field YoutubeSetupScreen uses, so
/// connecting here reflects automatically in the match creation flow too.
class StreamSettingsScreen extends StatefulWidget {
  const StreamSettingsScreen({super.key});

  @override
  State<StreamSettingsScreen> createState() => _StreamSettingsScreenState();
}

class _StreamSettingsScreenState extends State<StreamSettingsScreen> {
  final YouTubeService _youtubeService = YouTubeService();

  bool isConnected = false;
  String? channelName;
  String? channelImageUrl;
  bool isLoading = true;

  String get _userId => FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    setState(() => isLoading = true);
    final connected = await _youtubeService.isConnected(_userId);
    if (connected) {
      final info = await _youtubeService.getChannelInfo(_userId);
      channelName = info['name'];
      channelImageUrl = info['image'];
    }
    setState(() {
      isConnected = connected;
      isLoading = false;
    });
  }

  Future<void> _connect() async {
    try {
      await _youtubeService.connectYouTube(_userId);
      await _loadStatus();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to connect: $e')));
      }
    }
  }

  Future<void> _disconnect() async {
    await _youtubeService.disconnect(_userId);
    await _loadStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CustomAppBar(
        backgroundColor: AppColors.green,
        title: 'Stream Settings',
        showBackButton: true,
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
          padding: const EdgeInsets.all(24),
          child: isConnected ? _buildConnected() : _buildDisconnected(),
        ),
      ),
    );
  }

  Widget _buildConnected() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.grey.shade300,
            backgroundImage: channelImageUrl != null ? NetworkImage(channelImageUrl!) : null,
            child: channelImageUrl == null ? const Icon(Icons.person, color: Colors.grey) : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Connected Channel', style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 2),
                Text(channelName ?? 'Connected', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          TextButton(
            onPressed: _disconnect,
            child: const Text('Disconnect', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  Widget _buildDisconnected() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('YouTube', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        const Text('Connect your YouTube channel to go live', style: TextStyle(fontSize: 13, color: Colors.grey)),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: _connect,
            icon: const Icon(Icons.play_circle_fill, color: Colors.white, size: 20),
            label: const Text(
              'Login with YouTube',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }
}