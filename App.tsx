/**
 * Interval App - Main Application Entry Point
 */

import React, { useEffect, useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ActivityIndicator,
  SafeAreaView,
  StatusBar,
} from 'react-native';
import { Colors } from './src/constants/colors';
import { databaseService } from './src/services/database/DatabaseService';
import { categoryService } from './src/services/categories/CategoryService';

function App(): React.JSX.Element {
  const [isInitializing, setIsInitializing] = useState(true);
  const [error, setError] = useState<string | null>(null);

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

      setIsInitializing(false);
    } catch (err) {
      console.error('Failed to initialize app:', err);
      setError(err instanceof Error ? err.message : 'Unknown error');
      setIsInitializing(false);
    }
  };

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

  if (isInitializing) {
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
    <SafeAreaView style={styles.container}>
      <StatusBar barStyle="light-content" backgroundColor={Colors.black} />
      <View style={styles.content}>
        <Text style={styles.title}>Interval</Text>
        <Text style={styles.subtitle}>Minimalist Awareness Logger</Text>
        <View style={styles.statusContainer}>
          <Text style={styles.statusText}>✓ Database initialized</Text>
          <Text style={styles.statusText}>✓ Categories loaded</Text>
          <Text style={styles.statusText}>✓ Ready to log</Text>
        </View>
        <Text style={styles.infoText}>
          Foundation implementation complete.{'\n'}
          Next steps: Build navigation and screens.
        </Text>
      </View>
    </SafeAreaView>
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
  content: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20,
  },
  title: {
    fontSize: 48,
    fontWeight: '700',
    color: Colors.white,
    marginBottom: 8,
    letterSpacing: -1,
  },
  subtitle: {
    fontSize: 16,
    color: Colors.grey400,
    marginBottom: 60,
  },
  statusContainer: {
    alignItems: 'flex-start',
    marginBottom: 40,
  },
  statusText: {
    fontSize: 14,
    color: Colors.grey300,
    marginBottom: 8,
    fontFamily: 'monospace',
  },
  infoText: {
    fontSize: 14,
    color: Colors.grey500,
    textAlign: 'center',
    lineHeight: 20,
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
