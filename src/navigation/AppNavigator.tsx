/**
 * App Navigator - Main navigation setup
 */

import React from 'react';
import { Text } from 'react-native';
import { createStackNavigator } from '@react-navigation/stack';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { Colors } from '../constants/colors';

// Onboarding Screens
import { WelcomeScreen } from '../screens/Onboarding/WelcomeScreen';
import { IntervalSelectionScreen } from '../screens/Onboarding/IntervalSelectionScreen';
import { PermissionsScreen } from '../screens/Onboarding/PermissionsScreen';

// Main Screens
import { LoggingScreen } from '../screens/Logging/LoggingScreen';
import { HistoryScreen } from '../screens/History/HistoryScreen';
import { InsightsScreen } from '../screens/Insights/InsightsScreen';
import { SettingsScreen } from '../screens/Settings/SettingsScreen';

import type { RootStackParamList } from './types';

const Stack = createStackNavigator<RootStackParamList>();
const Tab = createBottomTabNavigator();

// Main Tab Navigator
const MainTabs = () => {
  return (
    <Tab.Navigator
      screenOptions={{
        headerShown: false,
        tabBarStyle: {
          backgroundColor: Colors.black,
          borderTopColor: Colors.grey900,
          borderTopWidth: 1,
        },
        tabBarActiveTintColor: Colors.white,
        tabBarInactiveTintColor: Colors.grey600,
        tabBarLabelStyle: {
          fontSize: 12,
          fontWeight: '500',
        },
      }}
    >
      <Tab.Screen
        name="Logging"
        component={LoggingScreen}
        options={{
          tabBarLabel: 'Log',
          tabBarIcon: ({ color }) => <TabIcon label="+" color={color} />,
        }}
      />
      <Tab.Screen
        name="History"
        component={HistoryScreen}
        options={{
          tabBarLabel: 'History',
          tabBarIcon: ({ color }) => <TabIcon label="≡" color={color} />,
        }}
      />
      <Tab.Screen
        name="Insights"
        component={InsightsScreen}
        options={{
          tabBarLabel: 'Insights',
          tabBarIcon: ({ color }) => <TabIcon label="◐" color={color} />,
        }}
      />
      <Tab.Screen
        name="Settings"
        component={SettingsScreen}
        options={{
          tabBarLabel: 'Settings',
          tabBarIcon: ({ color }) => <TabIcon label="⚙" color={color} />,
        }}
      />
    </Tab.Navigator>
  );
};

// Simple text-based tab icon (minimalist)
const TabIcon: React.FC<{ label: string; color: string }> = ({ label, color }) => (
  <Text style={{ fontSize: 24, color }}>{label}</Text>
);

// Root Stack Navigator
export const AppNavigator = () => {
  return (
    <Stack.Navigator
      screenOptions={{
        headerShown: false,
        cardStyle: { backgroundColor: Colors.black },
      }}
    >
      {/* Onboarding Flow */}
      <Stack.Screen name="Welcome" component={WelcomeScreen} />
      <Stack.Screen name="IntervalSelection" component={IntervalSelectionScreen} />
      <Stack.Screen name="Permissions" component={PermissionsScreen} />

      {/* Main App */}
      <Stack.Screen name="MainTabs" component={MainTabs} />
    </Stack.Navigator>
  );
};
