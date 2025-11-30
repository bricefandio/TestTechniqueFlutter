import React, { useState } from 'react';
import { View, Text, TextInput, Button } from 'react-native';

export default function HomeScreen({ navigation }: any) {
  const [userId, setUserId] = useState('');

  return (
    <View style={{ padding: 20 }}>
      <Text style={{ fontSize: 22, fontWeight: 'bold', marginBottom: 20 }}>
        Test Technique – App RN
      </Text>

      <Text>ID Utilisateur :</Text>
      <TextInput
        style={{
          borderWidth: 1,
          padding: 10,
          marginVertical: 10,
          borderRadius: 8
        }}
        keyboardType="numeric"
        value={userId}
        onChangeText={setUserId}
      />

      <Button
        title="Afficher le profil (Flutter)"
        onPress={() =>
          navigation.navigate('FlutterProfile', {
            userId: parseInt(userId, 10),
          })
        }
      />
    </View>
  );
}
