import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'features/auth/presentation/login_page.dart';
import 'features/launcher/presentation/launcher_page.dart';
import 'features/auth/services/auth_service.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ProviderScope(child: CivicAlertApp()));
}

class CivicAlertApp extends StatelessWidget {
  const CivicAlertApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vezi Civic Alert',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: FutureBuilder<User?>(
        future: FirebaseAuth.instance.authStateChanges().first,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final user = snapshot.data;

          if (user == null) {
            return const LoginPage();
          }

          return FutureBuilder<bool>(
            future: AuthService().isUserVerified(user.uid),
            builder: (context, verifiedSnapshot) {
              if (verifiedSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (verifiedSnapshot.hasError) {
                return const LoginPage(); // fallback în caz de eroare
              }

              if (verifiedSnapshot.data == true) {
                return const LauncherPage();
              } else {
                FirebaseAuth.instance.signOut(); // logout forțat
                return const LoginPage();
              }
            },
          );
        },
      ),
    );
  }
}
