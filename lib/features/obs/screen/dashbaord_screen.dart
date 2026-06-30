import 'package:flutter/material.dart';

import '../../../common/widgets/sidebar/cuex_sidebar.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Row(
        children: [
          // Sidebar
          CueXSidebar(selectedIndex: 0),

          // Main Content
          const Expanded(
            child: Center(
              child: Text(
                'Dashboard',
                style: TextStyle(
                  color: Color(0xFF10B981),
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}