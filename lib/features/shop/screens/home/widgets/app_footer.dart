import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      decoration: const BoxDecoration(

        border: Border(top: BorderSide(color: Color(0xFF1A1A1A))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          // Tagline
          Text(
            'Play Like A Pro 🎱',
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.7),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 32),

          // Divider
          Container(
            width: 40,
            height: 1,
            color: Colors.white.withOpacity(0.08),
          ),
          const SizedBox(height: 24),

          // Made with love
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Made with ',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  letterSpacing: 0.3,
                ),
              ),
              const Icon(Icons.favorite_rounded,
                  color: Colors.redAccent, size: 13),
              Text(
                ' in Bengaluru, India',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          // const SizedBox(height: 8),
          // Text(
          //   '© 2026 ZyvaLabs. All rights reserved.',
          //   style: TextStyle(
          //     fontSize: 10,
          //     color: Colors.grey.shade800,
          //     letterSpacing: 0.3,
          //   ),
          // ),
        ],
      ),
    );
  }
}