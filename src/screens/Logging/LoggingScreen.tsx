/**
 * Logging Screen - Main screen for creating log entries
 */

import React, { useState, useEffect, useRef } from 'react';
import {
  View,
  Text,
  StyleSheet,
  SafeAreaView,
  TextInput as RNTextInput,
  ScrollView,
  Alert,
} from 'react-native';
import { Colors } from '../../constants/colors';
import { Button } from '../../components/common/Button';
import { TextInput } from '../../components/common/TextInput';
import { Card } from '../../components/common/Card';
import { useLogsStore } from '../../store/logsStore';
import type { LoggingScreenNavigationProp, LoggingScreenRouteProp } from '../../navigation/types';
import { format } from 'date-fns';

interface LoggingScreenProps {
  navigation: LoggingScreenNavigationProp;
  route: LoggingScreenRouteProp;
}

export const LoggingScreen: React.FC<LoggingScreenProps> = ({ route }) => {
  const [logContent, setLogContent] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);
  const inputRef = useRef<RNTextInput>(null);

  const { logs, createLog, fetchTodayLogs, isLoading } = useLogsStore();
  const preselectedMode = route.params?.preselectedMode;

  useEffect(() => {
    // Auto-focus on mount
    setTimeout(() => {
      inputRef.current?.focus();
    }, 300);

    // Load today's logs
    fetchTodayLogs();
  }, []);

  const handleSubmit = async () => {
    if (!logContent.trim()) {
      Alert.alert('Empty Log', 'Please enter what you\'re doing.');
      return;
    }

    try {
      setIsSubmitting(true);

      await createLog({
        content: logContent.trim(),
        entryType: preselectedMode === 'voice' ? 'voice' : 'text',
        timestamp: Date.now(),
      });

      // Clear input and show success
      setLogContent('');
      inputRef.current?.focus();

      // Optional: Show brief success feedback
      Alert.alert('Logged', 'Activity logged successfully!', [{ text: 'OK' }]);
    } catch (error) {
      console.error('Failed to create log:', error);
      Alert.alert('Error', 'Failed to save log. Please try again.');
    } finally {
      setIsSubmitting(false);
    }
  };

  const recentLogs = logs.slice(0, 3);

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView
        style={styles.scrollView}
        contentContainerStyle={styles.scrollContent}
        keyboardShouldPersistTaps="handled"
      >
        <View style={styles.header}>
          <Text style={styles.title}>What are you doing now?</Text>
          <Text style={styles.time}>{format(new Date(), 'h:mm a')}</Text>
        </View>

        <View style={styles.inputSection}>
          <TextInput
            ref={inputRef}
            value={logContent}
            onChangeText={setLogContent}
            placeholder="Type your activity..."
            multiline
            numberOfLines={4}
            maxLength={500}
            showCounter
            style={styles.input}
            autoFocus
            onSubmitEditing={handleSubmit}
            returnKeyType="done"
            blurOnSubmit={false}
          />

          <Button
            title="Log Activity"
            onPress={handleSubmit}
            fullWidth
            loading={isSubmitting}
            disabled={!logContent.trim()}
          />
        </View>

        {recentLogs.length > 0 && (
          <View style={styles.recentSection}>
            <Text style={styles.sectionTitle}>Recent Logs</Text>
            {recentLogs.map((log) => (
              <Card key={log.id} style={styles.logCard}>
                <Text style={styles.logTime}>
                  {format(new Date(log.timestamp), 'h:mm a')}
                </Text>
                <Text style={styles.logContent}>{log.content}</Text>
                {log.category && (
                  <View style={styles.categoryBadge}>
                    <Text style={styles.categoryText}>{log.category}</Text>
                  </View>
                )}
              </Card>
            ))}
          </View>
        )}

        {isLoading && recentLogs.length === 0 && (
          <Text style={styles.loadingText}>Loading logs...</Text>
        )}

        {!isLoading && logs.length === 0 && (
          <View style={styles.emptyState}>
            <Text style={styles.emptyText}>No logs yet today.</Text>
            <Text style={styles.emptySubtext}>
              Start by logging your current activity above.
            </Text>
          </View>
        )}
      </ScrollView>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: Colors.black,
  },
  scrollView: {
    flex: 1,
  },
  scrollContent: {
    padding: 20,
  },
  header: {
    marginBottom: 32,
  },
  title: {
    fontSize: 28,
    fontWeight: '700',
    color: Colors.white,
    marginBottom: 8,
  },
  time: {
    fontSize: 16,
    color: Colors.grey500,
  },
  inputSection: {
    gap: 16,
    marginBottom: 40,
  },
  input: {
    minHeight: 120,
    textAlignVertical: 'top',
  },
  recentSection: {
    gap: 12,
  },
  sectionTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: Colors.grey400,
    marginBottom: 8,
  },
  logCard: {
    marginBottom: 8,
  },
  logTime: {
    fontSize: 12,
    color: Colors.grey500,
    marginBottom: 8,
  },
  logContent: {
    fontSize: 16,
    color: Colors.white,
    lineHeight: 22,
  },
  categoryBadge: {
    alignSelf: 'flex-start',
    backgroundColor: Colors.grey800,
    paddingHorizontal: 12,
    paddingVertical: 4,
    borderRadius: 12,
    marginTop: 8,
  },
  categoryText: {
    fontSize: 12,
    color: Colors.grey300,
    fontWeight: '500',
  },
  emptyState: {
    alignItems: 'center',
    paddingVertical: 40,
  },
  emptyText: {
    fontSize: 16,
    color: Colors.grey500,
    marginBottom: 8,
  },
  emptySubtext: {
    fontSize: 14,
    color: Colors.grey600,
    textAlign: 'center',
  },
  loadingText: {
    fontSize: 14,
    color: Colors.grey500,
    textAlign: 'center',
    paddingVertical: 20,
  },
});
