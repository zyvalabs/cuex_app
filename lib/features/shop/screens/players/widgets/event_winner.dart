import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../data/repositories/user/user_repository.dart';
import '../../../../personalization/models/user_model.dart';

class EventWinnerWidget extends StatelessWidget {
  const EventWinnerWidget({super.key, required this.winnerId});

  final String winnerId;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel>(
      future: Get.put(UserRepository()).fetchUserById(winnerId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 80,
            child: Center(
                child: CircularProgressIndicator(color: Colors.amber)),
          );
        }

        final winner = snapshot.data;
        if (winner == null || winner.id.isEmpty) return const SizedBox();

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.amber.withOpacity(0.15),
                Colors.orange.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.amber.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              // Trophy
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: Colors.amber.withOpacity(0.4), width: 1.5),
                ),
                child: const Icon(Iconsax.cup5,
                    color: Colors.amber, size: 24),
              ),
              const SizedBox(width: 16),

              // Winner info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TOURNAMENT WINNER',
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: 10,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      winner.fullName,
                      style: GoogleFonts.bebasNeue(
                        color: Colors.white,
                        fontSize: 22,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      '@${winner.userName}',
                      style: const TextStyle(
                          color: Colors.white38, fontSize: 12),
                    ),
                  ],
                ),
              ),

              // Avatar
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border:
                  Border.all(color: Colors.amber, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.3),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: const Color(0xFF222222),
                  backgroundImage: winner.profilePicture.isNotEmpty
                      ? NetworkImage(winner.profilePicture)
                      : null,
                  child: winner.profilePicture.isEmpty
                      ? Text(
                    winner.firstName.isNotEmpty
                        ? winner.firstName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                      : null,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}