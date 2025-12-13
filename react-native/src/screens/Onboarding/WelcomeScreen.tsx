/**
 * Welcome Screen - First onboarding screen
 */

import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Colors } from '../../constants/colors';
import { Button } from '../../components/common/Button';
import type { WelcomeScreenNavigationProp } from '../../navigation/types';

interface WelcomeScreenProps {
  navigation: WelcomeScreenNavigationProp;
}

export const WelcomeScreen: React.FC<WelcomeScreenProps> = ({ navigation }) => {
  const handleGetStarted = () => {
    navigation.navigate('IntervalSelection');
  };

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.content}>
        <View style={styles.header}>
          <Text style={styles.title}>Interval</Text>
          <Text style={styles.subtitle}>Minimalist Awareness Logger</Text>
        </View>

        <View style={styles.description}>
          <Text style={styles.descriptionText}>
            Build awareness through intentional reflection.
          </Text>
          <Text style={styles.descriptionText}>
            Every 15 or 30 minutes, pause and log what you're doing.
          </Text>
          <Text style={styles.descriptionText}>
            Simple. Mindful. Effective.
          </Text>
        </View>

        <View style={styles.footer}>
          <Button title="Get Started" onPress={handleGetStarted} fullWidth />
        </View>
      </View>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: Colors.black,
  },
  content: {
    flex: 1,
    paddingHorizontal: 32,
    justifyContent: 'space-between',
    paddingVertical: 60,
  },
  header: {
    alignItems: 'center',
    marginTop: 80,
  },
  title: {
    fontSize: 56,
    fontWeight: '700',
    color: Colors.white,
    letterSpacing: -2,
    marginBottom: 12,
  },
  subtitle: {
    fontSize: 16,
    color: Colors.grey400,
    letterSpacing: 1,
  },
  description: {
    gap: 24,
  },
  descriptionText: {
    fontSize: 18,
    color: Colors.grey300,
    textAlign: 'center',
    lineHeight: 26,
  },
  footer: {
    paddingBottom: 20,
  },
});
