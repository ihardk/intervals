/**
 * Permissions Screen - Request notification permissions
 */

import React, { useState } from 'react';
import { View, Text, StyleSheet, SafeAreaView, Alert } from 'react-native';
import { Colors } from '../../constants/colors';
import { Button } from '../../components/common/Button';
import { notificationService } from '../../services/notification/NotificationService';
import { useSettingsStore } from '../../store/settingsStore';
import type { PermissionsNavigationProp } from '../../navigation/types';

interface PermissionsScreenProps {
  navigation: PermissionsNavigationProp;
}

export const PermissionsScreen: React.FC<PermissionsScreenProps> = ({ navigation }) => {
  const [isLoading, setIsLoading] = useState(false);
  const updateSettings = useSettingsStore((state) => state.updateSettings);

  const handleRequestPermissions = async () => {
    try {
      setIsLoading(true);
      const granted = await notificationService.requestPermissions();

      if (granted) {
        await updateSettings({
          notificationsEnabled: true,
          onboardingCompleted: true,
        });

        // Initialize notification service
        await notificationService.initialize();

        // Navigate to main app (bottom tabs -> Capture)
        navigation.replace('MainTabs', { screen: 'Capture' });
      } else {
        Alert.alert(
          'Permissions Required',
          'Interval needs notification permissions to send you regular check-in reminders. Please enable them in Settings.',
          [{ text: 'OK' }]
        );
      }
    } catch (error) {
      console.error('Failed to request permissions:', error);
      Alert.alert('Error', 'Failed to request permissions. Please try again.');
    } finally {
      setIsLoading(false);
    }
  };

  const handleSkip = async () => {
    Alert.alert(
      'Skip Notifications?',
      "Without notifications, you won't receive regular reminders to log your activities. You can enable them later in Settings.",
      [
        { text: 'Cancel', style: 'cancel' },
        {
          text: 'Skip',
          style: 'destructive',
          onPress: async () => {
            await updateSettings({
              notificationsEnabled: false,
              onboardingCompleted: true,
            });
            navigation.replace('MainTabs', { screen: 'Capture' });
          },
        },
      ]
    );
  };

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.content}>
        <View>
          <Text style={styles.title}>Enable Notifications</Text>
          <Text style={styles.subtitle}>Interval works best with regular reminders</Text>

          <View style={styles.benefits}>
            <BenefitItem text="Receive gentle reminders every 15 or 30 minutes" />
            <BenefitItem text="Quick-log directly from notifications" />
            <BenefitItem text="Build consistent awareness habits" />
            <BenefitItem text="Never miss a check-in" />
          </View>

          <Text style={styles.note}>
            Notifications are essential for Interval to work as designed. You can customize or
            disable them later in Settings.
          </Text>
        </View>

        <View style={styles.footer}>
          <Button
            title="Enable Notifications"
            onPress={handleRequestPermissions}
            fullWidth
            loading={isLoading}
          />
          <Button
            title="Skip for Now"
            onPress={handleSkip}
            variant="ghost"
            fullWidth
            style={styles.skipButton}
          />
        </View>
      </View>
    </SafeAreaView>
  );
};

const BenefitItem: React.FC<{ text: string }> = ({ text }) => (
  <View style={styles.benefitItem}>
    <Text style={styles.benefitBullet}>•</Text>
    <Text style={styles.benefitText}>{text}</Text>
  </View>
);

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: Colors.black,
  },
  content: {
    flex: 1,
    paddingHorizontal: 32,
    paddingVertical: 40,
    justifyContent: 'space-between',
  },
  title: {
    fontSize: 32,
    fontWeight: '700',
    color: Colors.white,
    marginBottom: 12,
  },
  subtitle: {
    fontSize: 16,
    color: Colors.grey400,
    marginBottom: 40,
  },
  benefits: {
    gap: 16,
    marginBottom: 32,
  },
  benefitItem: {
    flexDirection: 'row',
    alignItems: 'flex-start',
  },
  benefitBullet: {
    fontSize: 20,
    color: Colors.white,
    marginRight: 12,
    lineHeight: 24,
  },
  benefitText: {
    flex: 1,
    fontSize: 16,
    color: Colors.grey300,
    lineHeight: 24,
  },
  note: {
    fontSize: 12,
    color: Colors.grey600,
    lineHeight: 18,
  },
  footer: {
    gap: 12,
    paddingBottom: 20,
  },
  skipButton: {
    marginTop: 8,
  },
});
