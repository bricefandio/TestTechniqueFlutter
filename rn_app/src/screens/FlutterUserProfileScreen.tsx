import React from 'react';
import { View, Text, Button } from 'react-native';
import { openFlutterUserProfile } from '../native/FlutterUserSdk';

export default function FlutterUserProfileScreen({ route }: any) {
  const { userId } = route.params;

  return (
    <View style={{ padding: 20 }}>
      <Text style={{ fontSize: 20, marginBottom: 20 }}>
        Ouvrir le profil Flutter pour userId = {userId}
      </Text>

      <Button
        title="Ouvrir l’écran Flutter"
        onPress={() => openFlutterUserProfile(userId)}
      />
    </View>
  );
}
