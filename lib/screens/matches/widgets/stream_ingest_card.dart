import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Shows stream ingest info — YouTube watch link (if applicable) is shown
/// prominently since that's what the user actually shares/watches.
/// RTMP URL + Stream Key are only shown for RTMP-platform matches, since
/// for YouTube the app configures the encoder automatically and doesn't
/// need to expose raw ingest credentials to the user.
class StreamIngestCard extends StatelessWidget {
  final String? youtubeLink;
  final String? rtmpUrl;
  final String? streamKey;

  const StreamIngestCard({
    super.key,
    this.youtubeLink,
    this.rtmpUrl,
    this.streamKey,
  });

  void _copyToClipboard(BuildContext context, String value, String label) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label copied')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Stream Setup', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          if (youtubeLink != null) _buildRow(context, 'YouTube Link', youtubeLink!),
          if (rtmpUrl != null) ...[
            const SizedBox(height: 10),
            _buildRow(context, 'RTMP URL', rtmpUrl!),
          ],
          if (streamKey != null) ...[
            const SizedBox(height: 10),
            _buildRow(context, 'Stream Key', streamKey!, obscure: true),
          ],
        ],
      ),
    );
  }

  Widget _buildRow(BuildContext context, String label, String value, {bool obscure = false}) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 2),
              Text(
                obscure ? '•' * value.length.clamp(0, 20) : value,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.copy, size: 18, color: Colors.grey),
          onPressed: () => _copyToClipboard(context, value, label),
        ),
      ],
    );
  }
}