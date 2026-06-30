import 'package:cuex_app/features/authentication/screens/welcome/welcome_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../home_menu.dart';
import '../../../../utils/constants/colors.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // still loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: CircularProgressIndicator(color: TColors.june),
            ),
          );
        }
        // logged in
        if (snapshot.hasData && snapshot.data != null) {
          return const HomeMenu();
        }
        // not logged in
        return const WelcomeScreen();
      },
    );
  }
}