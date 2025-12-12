/**
 * Interval App - Main Application Entry Point
 */

import React, { useEffect, useState } from 'react';
import { View, Text, StyleSheet, ActivityIndicator, SafeAreaView, StatusBar } from 'react-native';
import { NavigationContainer } from '@react-navigation/native';
import { Colors } from './src/constants/colors';
import { databaseService } from './src/services/database/DatabaseService';
import { categoryService } from './src/services/categories/CategoryService';
import { notificationService } from './src/services/notification/NotificationService';
import { useSettingsStore } from './src/store/settingsStore';
import { AppNavigator } from './src/navigation/AppNavigator';
import { navigationRef } from './src/navigation/NavigationService';

function App(): React.JSX.Element {
  const [isInitializing, setIsInitializing] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [initialRoute, setInitialRoute] = useState<string>('Welcome');

  const loadSettings = useSettingsStore((state) => state.loadSettings);
  const settings = useSettingsStore((state) => state.settings);

  useEffect(() => {
    initializeApp();
  }, []);

  const initializeApp = async () => {
    try {
      console.log('Initializing Interval app...');

      // Initialize database
      await databaseService.initialize();
      console.log('Database initialized');

      // Initialize default categories
      await categoryService.initializeDefaultCategories();
      console.log('Categories initialized');

      // Load settings
      await loadSettings();
      console.log('Settings loaded');

      // Initialize notifications if enabled
      await notificationService.initialize();
      console.log('Notification service initialized');

      setIsInitializing(false);
    } catch (err) {
      console.error('Failed to initialize app:', err);
      setError(err instanceof Error ? err.message : 'Unknown error');
      setIsInitializing(false);
    }
  };

  // Determine initial route based on onboarding status
  useEffect(() => {
    if (!isInitializing && settings) {
      if (settings.onboardingCompleted) {
        setInitialRoute('MainTabs');
      } else {
        setInitialRoute('Welcome');
      }
    }
  }, [isInitializing, settings]);

  if (error) {
    return (
      <SafeAreaView style={styles.container}>
        <StatusBar barStyle="light-content" backgroundColor={Colors.black} />
        <View style={styles.centered}>
          <Text style={styles.errorText}>Failed to initialize app</Text>
          <Text style={styles.errorDetails}>{error}</Text>
        </View>
      </SafeAreaView>
    );
  }

  if (isInitializing || !settings) {
    return (
      <SafeAreaView style={styles.container}>
        <StatusBar barStyle="light-content" backgroundColor={Colors.black} />
        <View style={styles.centered}>
          <ActivityIndicator size="large" color={Colors.white} />
          <Text style={styles.loadingText}>Initializing...</Text>
        </View>
      </SafeAreaView>
    );
  }

  return (
    <NavigationContainer ref={navigationRef}>
      <StatusBar barStyle="light-content" backgroundColor={Colors.black} />
      <AppNavigator />
    </NavigationContainer>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: Colors.black,
  },
  centered: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20,
  },
  loadingText: {
    fontSize: 16,
    color: Colors.white,
    marginTop: 16,
  },
  errorText: {
    fontSize: 18,
    color: Colors.error,
    fontWeight: '600',
    marginBottom: 8,
  },
  errorDetails: {
    fontSize: 14,
    color: Colors.grey400,
    textAlign: 'center',
  },
});

export default App;
