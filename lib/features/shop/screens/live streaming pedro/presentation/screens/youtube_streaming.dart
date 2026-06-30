import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../../common/widgets/youtube/youtube_widgets.dart';
import '../../../../../../data/services/youtube/youtube_service.dart';
import '../../../../../../utils/constants/colors.dart';

class YouTubeStreamingScreen extends StatefulWidget {
  const YouTubeStreamingScreen({super.key});

  @override
  State<YouTubeStreamingScreen> createState() => _YouTubeStreamingScreenState();
}

class _YouTubeStreamingScreenState extends State<YouTubeStreamingScreen> {
  final YouTubeService _youtubeService = YouTubeService();

  bool isConnected = false;
  String? channelName;
  String? channelImage;
  bool isLoading = true;
  bool isConnecting = false;
  bool isDisconnecting = false;

  String get userId => FirebaseAuth.instance.currentUser!.uid;

  static const _faqs = [
    {
      'q': 'Why do I need to connect YouTube?',
      'a': 'CueX uses your YouTube channel to create and manage live streams directly from the app when you start a match.',
    },
    {
      'q': 'Will my stream be public?',
      'a': 'Yes, streams are set to public by default so viewers can watch without signing in to YouTube.',
    },
    {
      'q': 'What if I don\'t have a YouTube channel?',
      'a': 'You need a YouTube channel to stream. Go to youtube.com and create one — it\'s free and takes less than 2 minutes.',
    },
    {
      'q': 'How do I enable live streaming on YouTube?',
      'a': 'Go to YouTube Studio → Go Live. If it\'s your first time, you\'ll need to verify your channel. Verification takes up to 24 hours.',
    },
    {
      'q': 'Can I change the connected account?',
      'a': 'Yes — tap Disconnect, then tap Connect YouTube Account again to choose a different Google account.',
    },
    {
      'q': 'How long does the stream stay live?',
      'a': 'The stream stays live until you stop it from the match screen. YouTube automatically saves it as a video after.',
    },
    {
      'q': 'What happens if the stream disconnects?',
      'a': 'If the internet drops, the stream pauses. Reconnect and resume streaming from the match screen.',
    },
    {
      'q': 'Can multiple matches stream at the same time?',
      'a': 'Yes — each match creates its own YouTube broadcast, so multiple tables can stream simultaneously.',
    },
    {
      'q': 'Where do viewers watch the match?',
      'a': 'Each match gets a unique YouTube link. Viewers can watch directly on your YouTube channel, or inside the CueX app — both work simultaneously.',
    },
    {
      'q': 'Is there a delay in the live stream?',
      'a': 'Yes, YouTube live streams have a 5–30 second delay depending on stream quality and viewer location.',
    },
    {
      'q': 'What internet speed do I need?',
      'a': 'Minimum 5 Mbps upload speed per stream. For 4 simultaneous streams, at least 25 Mbps upload is recommended.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadChannelData();
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.redAccent : Colors.green.shade700,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
    ));
  }

  Future<void> _loadChannelData() async {
    setState(() => isLoading = true);
    try {
      isConnected = await _youtubeService.isConnected(userId);
      if (isConnected) {
        final info = await _youtubeService.getChannelInfo(userId);
        channelName = info['name'];
        channelImage = info['image'];
      }
    } catch (e) {
      isConnected = false;
    }
    setState(() => isLoading = false);
  }

  Future<void> _connectYouTube() async {
    setState(() => isConnecting = true);
    try {
      await _youtubeService.connectYouTube(userId);
      await _loadChannelData();
      _showSnack('YouTube account connected!');
    } catch (e) {
      _showSnack(e.toString(), isError: true);
    }
    setState(() => isConnecting = false);
  }

  Future<void> _disconnectYouTube() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Disconnect YouTube?', style: TextStyle(color: Colors.white)),
        content: const Text('This will remove your YouTube account from CueX.',
            style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Disconnect', style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => isDisconnecting = true);
    await _youtubeService.disconnect(userId);
    setState(() {
      isConnected = false;
      channelName = null;
      channelImage = null;
      isDisconnecting = false;
    });
    _showSnack('YouTube account disconnected');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        title: const Text('YouTube Streaming',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadChannelData,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.redAccent))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isConnected) ...[
              _buildConnectedUI(),
            ] else ...[
              _buildDisconnectedUI(),
            ],
            const SizedBox(height: 32),
            _buildFAQ(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectedUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        YTChannelCard(
          channelName: channelName ?? 'Connected',
          channelImage: channelImage,
        ),
        const SizedBox(height: 16),

        // Status cards
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              YTInfoCard(
                icon: Icons.trending_up,
                title: 'Expand Your Audience',
                subtitle: 'Stream matches live to your YouTube subscribers automatically',
                iconColor: Colors.purpleAccent,
              ),
              const Divider(color: Color(0xFF2A2A2A), height: 24),
              YTInfoCard(
                icon: Icons.devices,
                title: 'Multi-Platform Viewing',
                subtitle: 'Viewers watch seamlessly on YouTube or inside the CueX app',
                iconColor: Colors.blueAccent,
              ),
              const Divider(color: Color(0xFF2A2A2A), height: 24),
              YTInfoCard(
                icon: Icons.bolt,
                title: 'Zero Setup Streaming',
                subtitle: 'CueX handles broadcast creation automatically — just hit Go Live',
                iconColor: Colors.orangeAccent,
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Verification notice
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: TColors.black,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: TColors.black),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Iconsax.verify, color: TColors.white, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Channel Verification Required',
                    style: TextStyle(
                      color: TColors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Your YouTube channel must be verified to enable live streaming. Verification takes up to 24 hours.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () async {
                  await launchUrl(Uri.parse('https://www.youtube.com/verify'));
                },
                child: Text(
                  'How to verify your channel →',
                  style: TextStyle(
                    color: TColors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                    decorationColor: TColors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Disconnect
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: isDisconnecting ? null : _disconnectYouTube,
            icon: isDisconnecting
                ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.redAccent))
                : const Icon(Icons.link_off, color: Colors.redAccent),
            label: Text(
              isDisconnecting ? 'Disconnecting...' : 'Disconnect YouTube',
              style: const TextStyle(color: Colors.redAccent),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.redAccent),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDisconnectedUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hero
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF2A2A2A)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.play_circle_fill,
                    color: Colors.redAccent, size: 48),
              ),
              const SizedBox(height: 16),
              const Text('Connect YouTube',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text(
                'Link your YouTube channel to go live directly from CueX matches.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Requirements
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const YTSectionHeader(title: 'Requirements'),
              _buildRequirement('YouTube channel with live streaming enabled'),
              _buildRequirement('Channel verified on YouTube Studio'),
              _buildRequirement('Live streaming enabled in YouTube settings'),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () async {
                  // open verify link
                },
                child: const Text(
                  'How to verify your channel →',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.redAccent,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Connect button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: isConnecting ? null : _connectYouTube,
            icon: isConnecting
                ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.link, color: Colors.white),
            label: Text(
              isConnecting ? 'Connecting...' : 'Connect YouTube Account',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFAQ() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const YTSectionHeader(title: 'Frequently Asked Questions'),
        ..._faqs.map((faq) => YTFAQTile(
          question: faq['q']!,
          answer: faq['a']!,
        )),
      ],
    );
  }

  Widget _buildRequirement(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, size: 16, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(
              child: Text(text,
                  style: const TextStyle(color: Colors.grey, fontSize: 12))),
        ],
      ),
    );
  }
}