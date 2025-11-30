import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user.dart';
import '../services/user_service.dart';

final userServiceProvider = Provider<UserService>((ref) {
  return UserService();
});

final userProfileControllerProvider = StateNotifierProvider.autoDispose
    .family<UserProfileController, AsyncValue<User>, int>((ref, userId) {
  final service = ref.watch(userServiceProvider);
  final controller = UserProfileController(
    userId: userId,
    userService: service,
  );
  controller.load();
  return controller;
});

class UserProfileController extends StateNotifier<AsyncValue<User>> {
  UserProfileController({
    required this.userId,
    required UserService userService,
  })  : _service = userService,
        super(const AsyncValue.loading());

  final int userId;
  final UserService _service;

  Future<void> load({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = _service.peek(userId);
      if (cached != null) {
        state = AsyncValue.data(cached);
        return;
      }
    }

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _service.fetchUser(userId, forceRefresh: forceRefresh),
    );
  }
}
