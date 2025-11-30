import React, { useEffect, useMemo, useState } from 'react';
import { Alert, Button, Text, TextInput, View } from 'react-native';

import { useUserId } from '../state/UserIdContext';

export default function HomeScreen() {
  const { loading, saveUserId, userId } = useUserId();
  const [inputValue, setInputValue] = useState('');

  useEffect(() => {
    if (userId !== null) {
      setInputValue(String(userId));
    }
  }, [userId]);

  const parsedUserId = useMemo(() => parseInt(inputValue, 10), [inputValue]);

  const handleSave = async () => {
    if (Number.isNaN(parsedUserId) || parsedUserId <= 0) {
      Alert.alert('ID invalide', 'Merci de saisir un entier positif.');
      return;
    }

    await saveUserId(parsedUserId);
    Alert.alert('ID sauvegardé', 'Le profil Flutter est rafraîchi automatiquement.');
  };

  return (
    <View style={{ padding: 24 }}>
      <Text style={{ fontSize: 22, fontWeight: 'bold', marginBottom: 20 }}>
        Saisissez l’identifiant utilisateur
      </Text>

      <Text>Identifiant (ex: 1 ou 3)</Text>
      <TextInput
        style={{
          borderWidth: 1,
          padding: 12,
          marginVertical: 10,
          borderRadius: 8,
          borderColor: '#ccc',
        }}
        placeholder="1"
        keyboardType="number-pad"
        value={inputValue}
        editable={!loading}
        onChangeText={setInputValue}
      />

      <Button title="Sauvegarder" onPress={handleSave} disabled={loading} />
    </View>
  );
}
