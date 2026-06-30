// ─────────────────────────────────────────────
// event_participants_screen.dart
// ─────────────────────────────────────────────

import 'package:cuex_app/features/shop/screens/event_particapnts/widgets/participation_action_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/popups/loaders.dart';
import '../../../personalization/controllers/user_controller.dart';
import '../../../personalization/models/user_model.dart';
import '../../controllers/event_registration_controller.dart';
import '../../models/event_participant_model.dart';
import '../event_particapnts/widgets/add_participant_button.dart';
import '../event_particapnts/widgets/particpiant_header.dart';
import '../matches/widgets/create_match.dart';
import '../players/player_stat_screen.dart';
import 'widgets/participant_row.dart';


class EventParticipantsScreen extends StatefulWidget {
  const EventParticipantsScreen({
    super.key,
    required this.eventId,
    this.selectMode = false,
    this.singleSelect = false,
    this.showCreateMatch = false,
    this.showHeader = true,
  });

  final String eventId;
  final bool selectMode;
  final bool singleSelect;
  final bool showCreateMatch;
  final bool showHeader;

  @override
  State<EventParticipantsScreen> createState() =>
      _EventParticipantsScreenState();
}

class _EventParticipantsScreenState extends State<EventParticipantsScreen> {
  late final EventParticipantController controller;
  final _userController = Get.find<UserController>();

  // ── State ─────────────────────────────────
  final _searchQuery = ''.obs;
  final Map<String, UserModel> _userCache = {};
  String? _selectedPlayer1Id;
  String? _selectedPlayer2Id;
  bool _isLoadingUsers = false;

  // ── Role helpers ──────────────────────────
  AppRole get _role => UserController.instance.user.value.role;
  bool get _isAdminOrPartner =>
      _role == AppRole.admin || _role == AppRole.partner;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<EventParticipantController>()
        ? Get.find<EventParticipantController>()
        : Get.put(EventParticipantController());
    _load();
  }

  // ── Load participants + cache users ───────
  Future<void> _load() async {
    await controller.fetchParticipantsByEvent(widget.eventId);
    setState(() => _isLoadingUsers = true);
    await Future.wait(
      controller.participants.map((p) async {
        if (!_userCache.containsKey(p.userId)) {
          try {
            final user = await _userController.getUserById(p.userId);
            _userCache[p.userId] = user;
          } catch (_) {}
        }
      }),
    );
    if (mounted) setState(() => _isLoadingUsers = false);
  }

  // ── Filtered list ─────────────────────────
  List<EventParticipantModel> get _filtered {
    final q = _searchQuery.value.toLowerCase();
    if (q.isEmpty) return controller.participants.toList();
    return controller.participants.where((p) {
      final user = _userCache[p.userId];
      if (user == null) return false;
      return '${user.firstName} ${user.lastName}'.toLowerCase().contains(q);
    }).toList();
  }

  // ── Handle participant tap ─────────────────
  Future<void> _handleTap(EventParticipantModel p, UserModel? user) async {
    // ✅ always fetch user if not cached
    UserModel? resolvedUser = user;
    if (resolvedUser == null || resolvedUser.id.isEmpty) {
      try {
        resolvedUser = await _userController.getUserById(p.userId);
        _userCache[p.userId] = resolvedUser;
      } catch (_) {}
    }

    if (_isAdminOrPartner) {
      _showActionSheet(p, resolvedUser);
      return;
    }

    if (_role == AppRole.player) {
      // ✅ show TAPPED player's stats, not logged-in user
      if (resolvedUser != null) {
        Get.to(() => PlayerStatsScreen(targetUser: resolvedUser));
      }
      return;
    }

    if (widget.singleSelect) {
      _returnSinglePlayer(p.userId);
    } else {
      _toggleSelection(p.userId);
    }
  }

  void _showActionSheet(EventParticipantModel p, UserModel? user) {
    final name = user != null
        ? '${user.firstName} ${user.lastName}'.trim()
        : 'Player';
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161616),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ParticipantActionSheet(
        participant: p,
        name: name,
        user: user,
        controller: controller,
        onRefresh: _load,
      ),
    );
  }

  Future<void> _returnSinglePlayer(String userId) async {
    try {
      final user = await _userController.getUserById(userId);
      if (mounted) {
        Navigator.pop(context, {
          'userId': user.id,
          'userName': '${user.firstName} ${user.lastName}'.trim(),
        });
      }
    } catch (e) {
      debugPrint('🔴 _returnSinglePlayer error: $e');
    }
  }

  void _toggleSelection(String userId) {
    setState(() {
      if (_selectedPlayer1Id == userId) {
        _selectedPlayer1Id = null;
      } else if (_selectedPlayer2Id == userId) {
        _selectedPlayer2Id = null;
      } else if (_selectedPlayer1Id == null) {
        _selectedPlayer1Id = userId;
      } else if (_selectedPlayer2Id == null) {
        _selectedPlayer2Id = userId;
      } else {
        TLoaders.warningSnackBar(
          title: 'Max Selection',
          message: 'You can only select 2 players',
        );
      }
    });
  }

  bool _isSelected(String userId) =>
      _selectedPlayer1Id == userId || _selectedPlayer2Id == userId;

  int get _selectedCount {
    int c = 0;
    if (_selectedPlayer1Id != null) c++;
    if (_selectedPlayer2Id != null) c++;
    return c;
  }

  void _createMatch() {
    if (_selectedPlayer1Id == null || _selectedPlayer2Id == null) {
      TLoaders.warningSnackBar(
        title: 'Incomplete',
        message: 'Please select 2 players',
      );
      return;
    }
    Get.back(result: {
      'player1Id': _selectedPlayer1Id,
      'player2Id': _selectedPlayer2Id,
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.showHeader) return _buildBody(context);

    return Scaffold(
      backgroundColor: TColors.peppercorn,
      appBar: TAppBar(
        showBackArrow: true,
        showActions: false,
        showSkipButton: false,
        title: Obx(() => Text(
          'Participants (${controller.participantCount.value})',
          style: Theme.of(context).textTheme.headlineMedium,
        )),
      ),
      bottomNavigationBar: _isAdminOrPartner
          ? AddParticipantButton(
        eventId: widget.eventId,
        onAdded: _load,
      )
          : null,
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Obx(() {
      // ── Shimmer ──────────────────────────
      if (controller.isLoading.value || _isLoadingUsers) {
        return const ParticipantShimmer();
      }

      // ── Empty ─────────────────────────────
      if (controller.participants.isEmpty) {
        return ParticipantsEmpty(
          isAdminOrPartner: _isAdminOrPartner,
          eventId: widget.eventId,
          onAdded: _load,
        );
      }

      final filtered = _filtered;

      return Column(
        children: [
          // ── Header when embedded ──────────
          if (!widget.showHeader && _isAdminOrPartner)
            ParticipantsHeader(
              eventId: widget.eventId,
              count: controller.participantCount.value,
              onAdded: _load,
            ),

          // ── Search bar ────────────────────
          ParticipantsSearchBar(
            query: _searchQuery,
            onChanged: (val) => _searchQuery.value = val,
            onClear: () => _searchQuery.value = '',
          ),

          // ── Create match banner ───────────
          if (widget.showCreateMatch && _selectedCount > 0)
            CreateMatchBanner(
              count: _selectedCount,
              onCreateMatch: _createMatch,
            ),

          // ── List ──────────────────────────
          Expanded(
            child: filtered.isEmpty
                ? Center(
              child: Text(
                'No results for "${_searchQuery.value}"',
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 13,
                ),
              ),
            )
                : RefreshIndicator(
              onRefresh: _load,
              color: TColors.june,
              backgroundColor: const Color(0xFF1C1C1C),
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(0, 4, 0, 100),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  color: Colors.white.withOpacity(0.05),
                ),
                itemBuilder: (_, i) {
                  final p = filtered[i];
                  final user = _userCache[p.userId];
                  return ParticipantRow(
                    participant: p,
                    user: user,
                    isSelected: _isSelected(p.userId),
                    isAdminOrPartner: _isAdminOrPartner,
                    onTap: () => _handleTap(p, user),
                  );
                },
              ),
            ),
          ),
        ],
      );
    });
  }
}


// ─────────────────────────────────────────────
// widgets/participant_shimmer.dart
// ─────────────────────────────────────────────

class ParticipantShimmer extends StatelessWidget {
  const ParticipantShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: 8,
      separatorBuilder: (_, __) => Divider(
        height: 1,
        color: Colors.white.withOpacity(0.05),
      ),
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            // Name + subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 120,
                    height: 13,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 80,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            // Badge
            Container(
              width: 60,
              height: 22,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// ─────────────────────────────────────────────
// widgets/participants_search_bar.dart
// ─────────────────────────────────────────────

class ParticipantsSearchBar extends StatelessWidget {
  const ParticipantsSearchBar({
    super.key,
    required this.query,
    required this.onChanged,
    required this.onClear,
  });

  final RxString query;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.07)),
        ),
        child: Obx(() => TextField(
          onChanged: onChanged,
          style: const TextStyle(fontSize: 13, color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search participants...',
            hintStyle: const TextStyle(
              fontSize: 13,
              color: Colors.white30,
            ),
            prefixIcon: const Icon(
              Iconsax.search_normal,
              size: 17,
              color: Colors.white30,
            ),
            suffixIcon: query.value.isNotEmpty
                ? GestureDetector(
              onTap: onClear,
              child: const Icon(
                Icons.close_rounded,
                size: 17,
                color: Colors.white38,
              ),
            )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        )),
      ),
    );
  }
}


// ─────────────────────────────────────────────
// widgets/participants_empty.dart
// ─────────────────────────────────────────────

class ParticipantsEmpty extends StatelessWidget {
  const ParticipantsEmpty({
    super.key,
    required this.isAdminOrPartner,
    required this.eventId,
    required this.onAdded,
  });

  final bool isAdminOrPartner;
  final String eventId;
  final VoidCallback onAdded;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Iconsax.people,
              size: 30,
              color: Colors.white24,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Participants Yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Add participants to get started',
            style: TextStyle(fontSize: 12, color: Colors.white38),
          ),
          if (isAdminOrPartner) ...[
            const SizedBox(height: 24),
            AddParticipantButton(
              eventId: eventId,
              onAdded: onAdded,
              inline: true,
            ),
          ],
        ],
      ),
    );
  }
}