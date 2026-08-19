import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/my_matches_controller.dart';


/// Shows the delete confirmation dialog and handles the actual delete +
/// navigation — kept separate so MatchDetailsScreen stays pure layout.
Future<void> showDeleteMatchDialog(BuildContext context, String matchId) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Delete Match?'),
      content: const Text('This will permanently delete this match. This cannot be undone.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Delete', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );

  if (confirmed != true) return;

  final myMatchesController =
  Get.isRegistered<MyMatchesController>() ? Get.find<MyMatchesController>() : null;

  final success = myMatchesController != null ? await myMatchesController.deleteMatch(matchId) : false;

  if (!context.mounted) return;

  if (success) {
    Navigator.of(context).pop(); // back to My Matches, list already updated
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Failed to delete match')),
    );
  }
}