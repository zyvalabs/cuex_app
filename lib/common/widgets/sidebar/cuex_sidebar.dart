import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../data/repositories/authentication/authentication_repository.dart';


class CueXSidebar extends StatelessWidget {
  final int selectedIndex;

  const CueXSidebar({super.key, this.selectedIndex = 0});

  static final _items = [
    _SidebarItem(icon: Iconsax.home, label: 'Dashboard', index: 0),
    _SidebarItem(icon: Iconsax.cup, label: 'Matches', index: 1),
    _SidebarItem(icon: Iconsax.camera, label: 'Cameras', index: 2),
    _SidebarItem(icon: Iconsax.setting, label: 'Settings', index: 3),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      color: const Color(0xFF111111),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 48, 20, 32),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Iconsax.cup, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                const Text(
                  'CueX',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),

          // Nav Items
          ..._items.map((item) => _buildNavItem(item, context)),

          const Spacer(),

          // Logout
          _buildLogoutButton(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildNavItem(_SidebarItem item, BuildContext context) {
    final isSelected = selectedIndex == item.index;
    return InkWell(
      onTap: () {
        if (item.index == 0) return;
        _showComingSoon(item.label, context);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF10B981).withOpacity(0.15) : Colors
              .transparent,
          borderRadius: BorderRadius.circular(10),
          border: isSelected
              ? Border.all(color: const Color(0xFF10B981).withOpacity(0.3))
              : null,
        ),
        child: Row(
          children: [
            Icon(
              item.icon,
              color: isSelected ? const Color(0xFF10B981) : Colors.white54,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              item.label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF10B981) : Colors.white54,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            if (item.index != 0) ...[
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Soon',
                  style: TextStyle(color: Colors.white38, fontSize: 10),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return GestureDetector(
      onTap: () async => await AuthenticationRepository.instance.logout(),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Row(
          children: [
            Icon(Iconsax.logout, color: Colors.redAccent, size: 20),
            SizedBox(width: 12),
            Text(
              'Logout',
              style: TextStyle(color: Colors.redAccent, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(String feature, BuildContext context) {
    showDialog(
      context: context,
      builder: (_) =>
          AlertDialog(
            backgroundColor: const Color(0xFF1A1A1A),
            title: const Text(
                'Coming Soon 🚧', style: TextStyle(color: Colors.white)),
            content: Text('$feature is under construction.',
                style: const TextStyle(color: Colors.white70)),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                      'OK', style: TextStyle(color: Color(0xFF10B981)))),
            ],
          ),
    );
  }
}

class _SidebarItem {
  final IconData icon;
  final String label;
  final int index;
  const _SidebarItem({required this.icon, required this.label, required this.index});
}