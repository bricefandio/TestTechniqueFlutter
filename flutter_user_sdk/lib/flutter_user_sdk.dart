import 'package:flutter/material.dart';

import 'src/screens/user_profile_screen.dart';

/// Public API used by the host app to render the AZEOO user profile widget.
class FlutterUserSDK {
  /// Returns a [Widget] that fetches and displays the AZEOO user profile
  /// corresponding to the provided [userId].
  static Widget showUserProfile(int userId) {
    return UserProfileScreen(userId: userId);
  }
}
