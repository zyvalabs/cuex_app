import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../personalization/controllers/user_controller.dart';
import '../../../controllers/event_registration_controller.dart';
import '../../../models/event_participant_model.dart';

class ParticipantSearchBar extends StatefulWidget {
  final String eventId;
  final void Function(EventParticipantModel participant, String fullName)? onSelected;
  final bool autoFocus;

  const ParticipantSearchBar({
    super.key,
    required this.eventId,
    this.onSelected,
    this.autoFocus = false,
  });

  @override
  State<ParticipantSearchBar> createState() => _ParticipantSearchBarState();
}

class _ParticipantSearchBarState extends State<ParticipantSearchBar> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final _layerLink = LayerLink();
  OverlayEntry? _overlay;

  final Map<String, String> _nameCache = {};
  List<_Entry> _filtered = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  late final EventParticipantController _pc;
  late final UserController _uc;

  @override
  void initState() {
    super.initState();
    _pc = Get.find<EventParticipantController>();
    _uc = Get.find<UserController>();
    _focusNode.addListener(() { if (!_focusNode.hasFocus) _removeOverlay(); });
    if (widget.autoFocus) _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _removeOverlay();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<String> _getName(String userId) async {
    if (_nameCache.containsKey(userId)) return _nameCache[userId]!;
    try {
      final user = await _uc.getUserById(userId);
      final name = '${user.firstName} ${user.lastName}'.trim();
      _nameCache[userId] = name;
      return name;
    } catch (_) {
      _nameCache[userId] = userId;
      return userId;
    }
  }

  Future<void> _onChanged(String query) async {
    if (query.trim().isEmpty) {
      _removeOverlay();
      setState(() { _filtered = []; _hasSearched = false; });
      return;
    }

    setState(() => _isLoading = true);

    final all = _pc.participants.toList();
    final entries = await Future.wait(all.map((p) async => _Entry(p, await _getName(p.userId))));
    final lower = query.toLowerCase();
    _filtered = entries.where((e) => e.name.toLowerCase().contains(lower)).toList();

    setState(() { _isLoading = false; _hasSearched = true; });
    _showOverlay();
  }

  void _showOverlay() {
    _removeOverlay();

    _overlay = OverlayEntry(builder: (_) => Positioned(
      width: 320,
      child: CompositedTransformFollower(
        link: _layerLink,
        showWhenUnlinked: false,
        offset: const Offset(0, 50),
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(12),
          child: _filtered.isEmpty
              ? const Padding(
            padding: EdgeInsets.all(16),
            child: Text('No participants found', style: TextStyle(color: Colors.grey)),
          )
              : ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 6),
            shrinkWrap: true,
            itemCount: _filtered.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final e = _filtered[i];
              return ListTile(
                dense: true,
                leading: CircleAvatar(
                  radius: 16,
                  child: Text(e.name.isNotEmpty ? e.name[0].toUpperCase() : '?', style: const TextStyle(fontSize: 13)),
                ),
                title: Text(e.name, style: const TextStyle(fontSize: 14)),
                subtitle: Text(e.participant.status.toUpperCase(), style: TextStyle(fontSize: 11, color: _statusColor(e.participant.status))),
                onTap: () {
                  _controller.clear();
                  _removeOverlay();
                  setState(() { _filtered = []; _hasSearched = false; });
                  widget.onSelected?.call(e.participant, e.name);
                },
              );
            },
          ),
        ),
      ),
    ));

    Overlay.of(context).insert(_overlay!);
  }

  void _removeOverlay() { _overlay?.remove(); _overlay = null; }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed': return Colors.green;
      case 'registered': return Colors.orange;
      case 'withdrawn': return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: SizedBox(
        height: 44,
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,
          onChanged: _onChanged,
          decoration: InputDecoration(
            hintText: 'Search participants...',
            prefixIcon: _isLoading
                ? const Padding(padding: EdgeInsets.all(10), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
                : const Icon(Icons.search, size: 20),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
              icon: const Icon(Icons.clear, size: 18),
              onPressed: () {
                _controller.clear();
                _removeOverlay();
                setState(() { _filtered = []; _hasSearched = false; });
              },
            )
                : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
        ),
      ),
    );
  }
}

class _Entry {
  final EventParticipantModel participant;
  final String name;
  const _Entry(this.participant, this.name);
}