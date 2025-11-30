import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'main.dart' show FlutterUserProfileApp;
import 'src/state/user_selection_notifier.dart';

/// Public API used by host applications embedding the Flutter UI directly in
/// another Flutter tree.
class FlutterUserSDK {
  /// Returns a widget hosting the full AZEOO profile experience managed by the
  /// SDK, optionally pre-populated with [initialUserId].
  static Widget experience({int? initialUserId}) {
    return ProviderScope(
      overrides: [
        userSelectionProvider.overrideWith(
          (ref) => UserSelectionNotifier(initialUserId: initialUserId),
        ),
      ],
      child: const FlutterUserProfileApp(),
    );
  }
}
