import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../utils/constants/enums.dart';
import '../../../../../utils/popups/loaders.dart';
import '../../../controllers/matches_controller.dart';
import '../../../models/match_model.dart';
import '../../../../personalization/controllers/user_controller.dart';
import '../../matches/create_match_screen.dart';

class MatchOptionsMenu {
  static const String _tag = 'MatchOptionsMenu';

  static void show(BuildContext context, MatchModel match) {
    final role = UserController.instance.user.value.role;
    debugPrint('[$_tag] show — role: $role, matchId: ${match.id}');

    if (role != AppRole.admin && role != AppRole.partner) {
      debugPrint('[$_tag] show — unauthorized role, returning');
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111111),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Iconsax.edit, color: Colors.white),
              title: const Text('Edit Match', style: TextStyle(color: Colors.white)),
              onTap: () {
                debugPrint('[$_tag] show — edit tapped, matchId: ${match.id}');
                Navigator.of(sheetContext).pop();
                Get.to(() => CreateMatchScreen(
                  eventId: match.eventId,
                  existingMatch: match,
                ));
              },
            ),
            ListTile(
              leading: const Icon(Iconsax.trash, color: Colors.red),
              title: const Text('Delete Match', style: TextStyle(color: Colors.red)),
              onTap: () {
                debugPrint('[$_tag] show — delete tapped, matchId: ${match.id}');
                Navigator.of(sheetContext).pop();
                _confirmDelete(context, match);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  static void _confirmDelete(BuildContext context, MatchModel match) {
    debugPrint('[$_tag] _confirmDelete — matchId: ${match.id}');
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF111111),
        title: const Text('Delete Match', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure? This cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              debugPrint('[$_tag] _confirmDelete — cancelled');
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop(); // close dialog
              try {
                await MatchController.instance.matchRepository.deleteItem(match);
                debugPrint('[$_tag] _confirmDelete — match deleted from Firestore');
                await MatchController.instance.fetchLiveMatches();
                await MatchController.instance.fetchUpcomingMatches();
                await MatchController.instance.fetchCompletedMatches();
                debugPrint('[$_tag] _confirmDelete — match lists refreshed');
                TLoaders.successSnackBar(title: 'Deleted', message: 'Match deleted'); // ← before pop
                Navigator.of(context).pop(); // pop LiveScoringScreen
              } catch (e, stack) {
                debugPrint('[$_tag] _confirmDelete — error: $e');
                debugPrint('[$_tag] _confirmDelete — stack: $stack');
                TLoaders.errorSnackBar(title: 'Error', message: e.toString());
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}