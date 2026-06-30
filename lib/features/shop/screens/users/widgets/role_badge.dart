import 'package:flutter/material.dart';
import '../../../../../utils/constants/enums.dart';

class RoleBadge extends StatelessWidget {
  const RoleBadge({super.key, required this.role});
  final AppRole role;

  Color get _color {
    switch (role) {
      case AppRole.admin: return Colors.purple;
      case AppRole.partner: return Colors.blue;
      case AppRole.player: return Colors.green;
    }
  }

  String get _label {
    switch (role) {
      case AppRole.admin: return 'Admin';
      case AppRole.partner: return 'Partner';
      case AppRole.player: return 'Player';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: _color.withOpacity(0.3)),
      ),
      child: Text(
        _label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _color),
      ),
    );
  }
}