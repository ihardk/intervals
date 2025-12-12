/**
 * Interval Selection Screen - Choose 15 or 30 minute intervals
 */

import React, { useState } from 'react';
import { View, Text, StyleSheet, SafeAreaView, TouchableOpacity } from 'react-native';
import { Colors } from '../../constants/colors';
import { Button } from '../../components/common/Button';
import { IntervalDuration } from '../../constants/intervals';
import { useSettingsStore } from '../../store/settingsStore';
import type { IntervalSelectionNavigationProp } from '../../navigation/types';

interface IntervalSelectionScreenProps {
  navigation: IntervalSelectionNavigationProp;
}

export const IntervalSelectionScreen: React.FC<IntervalSelectionScreenProps> = ({
  navigation,
}) => {
  const [selectedInterval, setSelectedInterval] = useState<number>(
    IntervalDuration.FIFTEEN_MINUTES
  );
  const updateSetting = useSettingsStore((state) => state.updateSetting);
  const [isLoading, setIsLoading] = useState(false);

  const handleNext = async () => {
    try {
      setIsLoading(true);
      await updateSetting('intervalDuration', selectedInterval);
      navigation.navigate('Permissions');
    } catch (error) {
      console.error('Failed to save interval:', error);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.content}>
        <View>
          <Text style={styles.title}>Choose Your Interval</Text>
          <Text style={styles.subtitle}>How often would you like to check in?</Text>

          <View style={styles.options}>
            <TouchableOpacity
              style={[
                styles.optionCard,
                selectedInterval === IntervalDuration.FIFTEEN_MINUTES && styles.optionSelected,
              ]}
              onPress={() => setSelectedInterval(IntervalDuration.FIFTEEN_MINUTES)}
              activeOpacity={0.7}
            >
              <Text
                style={[
                  styles.optionTitle,
                  selectedInterval === IntervalDuration.FIFTEEN_MINUTES &&
                    styles.optionTitleSelected,
                ]}
              >
                15 minutes
              </Text>
              <Text style={styles.optionDescription}>More frequent check-ins</Text>
              <Text style={styles.optionDescription}>~32 reminders per day</Text>
            </TouchableOpacity>

            <TouchableOpacity
              style={[
                styles.optionCard,
                selectedInterval === IntervalDuration.THIRTY_MINUTES && styles.optionSelected,
              ]}
              onPress={() => setSelectedInterval(IntervalDuration.THIRTY_MINUTES)}
              activeOpacity={0.7}
            >
              <Text
                style={[
                  styles.optionTitle,
                  selectedInterval === IntervalDuration.THIRTY_MINUTES &&
                    styles.optionTitleSelected,
                ]}
              >
                30 minutes
              </Text>
              <Text style={styles.optionDescription}>Balanced awareness</Text>
              <Text style={styles.optionDescription}>~16 reminders per day</Text>
            </TouchableOpacity>
          </View>

          <Text style={styles.note}>You can change this later in Settings</Text>
        </View>

        <View style={styles.footer}>
          <Button title="Next" onPress={handleNext} fullWidth loading={isLoading} />
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
  options: {
    gap: 16,
  },
  optionCard: {
    backgroundColor: Colors.grey900,
    borderWidth: 2,
    borderColor: Colors.grey800,
    borderRadius: 8,
    padding: 24,
  },
  optionSelected: {
    borderColor: Colors.white,
    backgroundColor: Colors.grey800,
  },
  optionTitle: {
    fontSize: 24,
    fontWeight: '600',
    color: Colors.grey300,
    marginBottom: 8,
  },
  optionTitleSelected: {
    color: Colors.white,
  },
  optionDescription: {
    fontSize: 14,
    color: Colors.grey500,
    lineHeight: 20,
  },
  note: {
    fontSize: 12,
    color: Colors.grey600,
    textAlign: 'center',
    marginTop: 24,
  },
  footer: {
    paddingBottom: 20,
  },
});
