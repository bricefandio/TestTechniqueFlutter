import { NativeModules } from 'react-native';

const { FlutterUserSdk } = NativeModules;

export function openFlutterUserProfile(userId: number) {
  if (!FlutterUserSdk) {
    console.error('❌ Native module FlutterUserSdk non trouvé.');
    return;
  }

  FlutterUserSdk.openUserProfile(userId);
}
