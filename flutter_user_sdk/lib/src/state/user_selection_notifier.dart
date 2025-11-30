import 'package:flutter_riverpod/flutter_riverpod.dart';

final userSelectionProvider =
    StateNotifierProvider<UserSelectionNotifier, int?>(
  (ref) => UserSelectionNotifier(),
);

class UserSelectionNotifier extends StateNotifier<int?> {
  UserSelectionNotifier({int? initialUserId}) : super(initialUserId);

  void setUserId(int? userId) {
    if (userId == state) {
      return;
    }
    state = userId;
  }
}
