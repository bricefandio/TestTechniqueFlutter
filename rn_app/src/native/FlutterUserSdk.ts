import { NativeModules } from 'react-native';

const { FlutterUserSdk } = NativeModules;

export async function openFlutterUserProfile(userId: number) {
  if (!FlutterUserSdk) {
    console.error('❌ Native module FlutterUserSdk non trouvé.');
    return;
  }

  try {
    await FlutterUserSdk.openUserProfile(userId);
  } catch (error) {
    console.error('Erreur lors de l’ouverture du profil Flutter', error);
  }
}
