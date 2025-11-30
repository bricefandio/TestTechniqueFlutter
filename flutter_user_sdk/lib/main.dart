import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/navigation/app_router.dart';
import 'src/state/profile_controller.dart';
import 'src/state/user_selection_notifier.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final initialUserId =
      _extractUserId(WidgetsBinding.instance.platformDispatcher.defaultRouteName);

  runApp(
    ProviderScope(
      overrides: [
        userSelectionProvider.overrideWith(
          (ref) => UserSelectionNotifier(initialUserId: initialUserId),
        ),
      ],
      child: const FlutterUserProfileApp(),
    ),
  );
}

class FlutterUserProfileApp extends ConsumerStatefulWidget {
  const FlutterUserProfileApp({super.key});

  @override
  ConsumerState<FlutterUserProfileApp> createState() => _FlutterUserProfileAppState();
}

class _FlutterUserProfileAppState extends ConsumerState<FlutterUserProfileApp> {
  static const _channel = MethodChannel('flutter_user_sdk/user');

  @override
  void initState() {
    super.initState();
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'showUserProfile':
        final userId = _parseUserId(call.arguments);
        if (userId != null) {
          ref.read(userSelectionProvider.notifier).setUserId(userId);
        }
        break;
      case 'refreshUserProfile':
        final currentUserId = ref.read(userSelectionProvider);
        if (currentUserId != null) {
          await ref
              .read(userProfileControllerProvider(currentUserId).notifier)
              .load(forceRefresh: true);
        }
        break;
      default:
    }
  }

  @override
  void dispose() {
    _channel.setMethodCallHandler(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'AZEOO User SDK',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}

int? _extractUserId(String route) {
  final uri = Uri.tryParse(route);
  if (uri == null) {
    return null;
  }
  if (uri.path == '/profile') {
    final userParam = uri.queryParameters['userId'];
    return int.tryParse(userParam ?? '');
  }
  return null;
}

int? _parseUserId(dynamic args) {
  if (args is Map) {
    final value = args['userId'];
    if (value is int) {
      return value;
    }
    return int.tryParse(value?.toString() ?? '');
  }
  if (args is int) {
    return args;
  }
  return int.tryParse(args?.toString() ?? '');
}
