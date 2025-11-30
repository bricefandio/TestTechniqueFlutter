import 'package:flutter/material.dart';
import 'package:flutter_user_sdk/flutter_user_sdk.dart';

void main() {
  runApp(const MyTestApp());
}

class MyTestApp extends StatelessWidget {
  const MyTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FlutterUserSDK.showUserProfile(1), // test avec userId 1
    );
  }
}
