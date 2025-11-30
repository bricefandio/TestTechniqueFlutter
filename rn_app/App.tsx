import { NavigationContainer } from '@react-navigation/native';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import React from 'react';
import { enableScreens } from 'react-native-screens';
import { SafeAreaProvider } from 'react-native-safe-area-context';

import FlutterUserProfileScreen from './src/screens/FlutterUserProfileScreen';
import HomeScreen from './src/screens/HomeScreen';
import { UserIdProvider } from './src/state/UserIdContext';

enableScreens();

const Tab = createBottomTabNavigator();

export default function App() {
  return (
    <SafeAreaProvider>
      <UserIdProvider>
        <NavigationContainer>
          <Tab.Navigator>
            <Tab.Screen
              name="userId"
              component={HomeScreen}
              options={{ title: 'Identifiant' }}
            />
            <Tab.Screen
              name="flutterProfile"
              component={FlutterUserProfileScreen}
              options={{ title: 'Profil Flutter' }}
            />
          </Tab.Navigator>
        </NavigationContainer>
      </UserIdProvider>
    </SafeAreaProvider>
  );
}