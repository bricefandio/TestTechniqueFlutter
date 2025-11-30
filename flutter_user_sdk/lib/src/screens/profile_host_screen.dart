import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/user_selection_notifier.dart';
import 'user_profile_screen.dart';

class ProfileHostScreen extends ConsumerWidget {
  const ProfileHostScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(userSelectionProvider);

    if (userId == null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.person_search_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 72,
                ),
                const SizedBox(height: 16),
                Text(
                  'Aucun utilisateur sélectionné.',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Choisissez un userId dans l’application hôte pour afficher le profil Flutter.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return UserProfileScreen(userId: userId);
  }
}
