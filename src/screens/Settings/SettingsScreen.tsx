/**
 * Settings Screen - App configuration
 */

import React, { useEffect, useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  SafeAreaView,
  ScrollView,
  Switch,
  TouchableOpacity,
  Alert,
} from 'react-native';
import { Colors } from '../../constants/colors';
import { Card } from '../../components/common/Card';
import { useSettingsStore } from '../../store/settingsStore';
import { IntervalDuration, AVAILABLE_INTERVALS } from '../../constants/intervals';

export const SettingsScreen: React.FC = () => {
  const { settings, loadSettings, updateSetting, isLoading } = useSettingsStore();
  const [localSettings, setLocalSettings] = useState(settings);

  useEffect(() => {
    loadSettings();
  }, []);

  useEffect(() => {
    setLocalSettings(settings);
  }, [settings]);

  const handleToggle = async (key: keyof typeof settings, value: boolean) => {
    setLocalSettings((prev) => (prev ? { ...prev, [key]: value } : prev));
    try {
      await updateSetting(key as any, value);
    } catch (error) {
      console.error('Failed to update setting:', error);
      // Revert on error
      setLocalSettings(settings);
    }
  };

  const handleIntervalChange = () => {
    const currentInterval = localSettings?.intervalDuration;
    const newInterval =
      currentInterval === IntervalDuration.FIFTEEN_MINUTES
        ? IntervalDuration.THIRTY_MINUTES
        : IntervalDuration.FIFTEEN_MINUTES;

    const intervalLabel = newInterval === IntervalDuration.FIFTEEN_MINUTES ? '15' : '30';

    Alert.alert(
      'Change Interval',
      `Switch to ${intervalLabel} minute intervals?`,
      [
        { text: 'Cancel', style: 'cancel' },
        {
          text: 'Change',
          onPress: async () => {
            setLocalSettings((prev) =>
              prev ? { ...prev, intervalDuration: newInterval } : prev
            );
            try {
              await updateSetting('intervalDuration', newInterval);
            } catch (error) {
              console.error('Failed to update interval:', error);
              setLocalSettings(settings);
            }
          },
        },
      ]
    );
  };

  if (isLoading || !localSettings) {
    return (
      <SafeAreaView style={styles.container}>
        <Text style={styles.loadingText}>Loading settings...</Text>
      </SafeAreaView>
    );
  }

  const currentIntervalLabel =
    localSettings.intervalDuration === IntervalDuration.FIFTEEN_MINUTES ? '15 minutes' : '30 minutes';

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.title}>Settings</Text>
      </View>

      <ScrollView style={styles.scrollView} contentContainerStyle={styles.scrollContent}>
        <Card style={styles.section}>
          <Text style={styles.sectionTitle}>Notifications</Text>

          <SettingRow
            label="Enable Notifications"
            description="Receive interval reminders"
            value={localSettings.notificationsEnabled}
            onValueChange={(value) => handleToggle('notificationsEnabled', value)}
          />

          <View style={styles.divider} />

          <TouchableOpacity
            style={styles.settingRow}
            onPress={handleIntervalChange}
            activeOpacity={0.7}
          >
            <View style={styles.settingInfo}>
              <Text style={styles.settingLabel}>Interval Duration</Text>
              <Text style={styles.settingDescription}>How often to receive reminders</Text>
            </View>
            <Text style={styles.settingValue}>{currentIntervalLabel}</Text>
          </TouchableOpacity>
        </Card>

        <Card style={styles.section}>
          <Text style={styles.sectionTitle}>Features</Text>

          <SettingRow
            label="Voice Input"
            description="Enable voice recording and transcription"
            value={localSettings.voiceEnabled}
            onValueChange={(value) => handleToggle('voiceEnabled', value)}
          />

          <View style={styles.divider} />

          <SettingRow
            label="Auto-Categorize"
            description="Automatically detect activity categories"
            value={localSettings.autoCategorize}
            onValueChange={(value) => handleToggle('autoCategorize', value)}
          />
        </Card>

        <Card style={styles.section}>
          <Text style={styles.sectionTitle}>About</Text>
          <View style={styles.aboutRow}>
            <Text style={styles.aboutLabel}>Version</Text>
            <Text style={styles.aboutValue}>1.0.0</Text>
          </View>
          <View style={styles.divider} />
          <View style={styles.aboutRow}>
            <Text style={styles.aboutLabel}>Build</Text>
            <Text style={styles.aboutValue}>MVP Alpha</Text>
          </View>
        </Card>
      </ScrollView>
    </SafeAreaView>
  );
};

interface SettingRowProps {
  label: string;
  description: string;
  value: boolean;
  onValueChange: (value: boolean) => void;
}

const SettingRow: React.FC<SettingRowProps> = ({ label, description, value, onValueChange }) => (
  <View style={styles.settingRow}>
    <View style={styles.settingInfo}>
      <Text style={styles.settingLabel}>{label}</Text>
      <Text style={styles.settingDescription}>{description}</Text>
    </View>
    <Switch
      value={value}
      onValueChange={onValueChange}
      trackColor={{ false: Colors.grey700, true: Colors.grey500 }}
      thumbColor={value ? Colors.white : Colors.grey400}
    />
  </View>
);

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: Colors.black,
  },
  header: {
    paddingHorizontal: 20,
    paddingTop: 20,
    paddingBottom: 16,
    borderBottomWidth: 1,
    borderBottomColor: Colors.grey900,
  },
  title: {
    fontSize: 32,
    fontWeight: '700',
    color: Colors.white,
  },
  scrollView: {
    flex: 1,
  },
  scrollContent: {
    padding: 20,
  },
  section: {
    marginBottom: 20,
  },
  sectionTitle: {
    fontSize: 14,
    fontWeight: '600',
    color: Colors.grey500,
    marginBottom: 16,
    textTransform: 'uppercase',
    letterSpacing: 0.5,
  },
  settingRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingVertical: 12,
  },
  settingInfo: {
    flex: 1,
    marginRight: 16,
  },
  settingLabel: {
    fontSize: 16,
    fontWeight: '500',
    color: Colors.white,
    marginBottom: 4,
  },
  settingDescription: {
    fontSize: 14,
    color: Colors.grey500,
    lineHeight: 18,
  },
  settingValue: {
    fontSize: 16,
    color: Colors.grey400,
    fontWeight: '500',
  },
  divider: {
    height: 1,
    backgroundColor: Colors.grey800,
    marginVertical: 8,
  },
  aboutRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingVertical: 12,
  },
  aboutLabel: {
    fontSize: 16,
    color: Colors.grey400,
  },
  aboutValue: {
    fontSize: 16,
    color: Colors.grey500,
    fontFamily: 'monospace',
  },
  loadingText: {
    fontSize: 16,
    color: Colors.grey500,
    textAlign: 'center',
    marginTop: 40,
  },
});
