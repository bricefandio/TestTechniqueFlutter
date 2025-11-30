import { useFocusEffect } from '@react-navigation/native';
import React, { useCallback } from 'react';
import { Button, Text, View } from 'react-native';

import { openFlutterUserProfile } from '../native/FlutterUserSdk';
import { useUserId } from '../state/UserIdContext';

export default function FlutterUserProfileScreen() {
  const { userId } = useUserId();

  useFocusEffect(
    useCallback(() => {
      if (userId != null) {
        openFlutterUserProfile(userId);
      }
    }, [userId]),
  );

  if (userId == null) {
    return (
      <View style={{ padding: 24 }}>
        <Text style={{ fontSize: 18, marginBottom: 12 }}>
          Aucun userId renseigné.
        </Text>
        <Text>
          Saisissez un identifiant dans l’onglet “Identifiant” pour que l’écran Flutter affiche le
          profil.
        </Text>
      </View>
    );
  }

  return (
    <View style={{ padding: 24 }}>
      <Text style={{ fontSize: 18, marginBottom: 12 }}>
        Profil Flutter pour l’utilisateur {userId}
      </Text>
      <Text style={{ marginBottom: 16 }}>
        L’écran Flutter est affiché automatiquement via le module natif.
      </Text>
      <Button title="Relancer / rafraîchir" onPress={() => openFlutterUserProfile(userId)} />
    </View>
  );
}
