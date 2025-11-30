import 'package:flutter/material.dart';
import 'package:flutter_user_sdk/src/screens/user_profile_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FlutterUserProfileApp());
}

class FlutterUserProfileApp extends StatelessWidget {
  const FlutterUserProfileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AZEOO User SDK',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      onGenerateRoute: (settings) {
        final uri =
            Uri.tryParse(settings.name ?? '') ??
            Uri(path: settings.name ?? '/');

        if (uri.path == '/profile') {
          final userIdParam = uri.queryParameters['userId'];
          final userId = int.tryParse(userIdParam ?? '');

          if (userId != null) {
            return MaterialPageRoute<void>(
              builder: (_) => UserProfileScreen(userId: userId),
            );
          }

          return MaterialPageRoute<void>(
            builder: (_) => const _ErrorScreen(
              message:
                  'Paramètre userId manquant ou invalide pour la route /profile.',
            ),
          );
        }

        return MaterialPageRoute<void>(
          builder: (_) => const _ErrorScreen(
            message: 'Route inconnue. Utilisez /profile?userId=<id>.',
          ),
        );
      },
    );
  }
}

class _ErrorScreen extends StatelessWidget {
  final String message;

  const _ErrorScreen({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ),
    );
  }
}
