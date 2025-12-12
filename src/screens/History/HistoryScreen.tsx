/**
 * History Screen - View all logged activities
 */

import React, { useEffect, useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  SafeAreaView,
  FlatList,
  RefreshControl,
  TouchableOpacity,
} from 'react-native';
import { Colors } from '../../constants/colors';
import { Card } from '../../components/common/Card';
import { useLogsStore } from '../../store/logsStore';
import { format, isToday, isYesterday, startOfDay } from 'date-fns';
import type { Log } from '../../models/Log';

export const HistoryScreen: React.FC = () => {
  const { logs, fetchTodayLogs, isLoading } = useLogsStore();
  const [refreshing, setRefreshing] = useState(false);

  useEffect(() => {
    fetchTodayLogs();
  }, []);

  const onRefresh = async () => {
    setRefreshing(true);
    await fetchTodayLogs();
    setRefreshing(false);
  };

  const renderDateHeader = (date: Date) => {
    let dateLabel = format(date, 'MMMM d, yyyy');

    if (isToday(date)) {
      dateLabel = 'Today';
    } else if (isYesterday(date)) {
      dateLabel = 'Yesterday';
    }

    return (
      <View style={styles.dateHeader}>
        <Text style={styles.dateHeaderText}>{dateLabel}</Text>
      </View>
    );
  };

  const renderLog = ({ item, index }: { item: Log; index: number }) => {
    // Show date header if first item or different day from previous
    const showDateHeader =
      index === 0 ||
      startOfDay(item.timestamp).getTime() !==
        startOfDay(logs[index - 1].timestamp).getTime();

    return (
      <View>
        {showDateHeader && renderDateHeader(new Date(item.timestamp))}
        <TouchableOpacity activeOpacity={0.7}>
          <Card style={styles.logCard}>
            <View style={styles.logHeader}>
              <Text style={styles.logTime}>{format(new Date(item.timestamp), 'h:mm a')}</Text>
              {item.entryType === 'voice' && <Text style={styles.voiceIndicator}>🎤</Text>}
            </View>
            <Text style={styles.logContent}>{item.content}</Text>
            {item.category && (
              <View style={styles.categoryBadge}>
                <Text style={styles.categoryText}>{item.category}</Text>
              </View>
            )}
          </Card>
        </TouchableOpacity>
      </View>
    );
  };

  const renderEmpty = () => (
    <View style={styles.emptyState}>
      <Text style={styles.emptyTitle}>No logs yet</Text>
      <Text style={styles.emptyText}>
        Start logging your activities to build your history
      </Text>
    </View>
  );

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.title}>History</Text>
        <Text style={styles.subtitle}>{logs.length} logs today</Text>
      </View>

      <FlatList
        data={logs}
        renderItem={renderLog}
        keyExtractor={(item) => item.id}
        contentContainerStyle={styles.listContent}
        refreshControl={
          <RefreshControl
            refreshing={refreshing}
            onRefresh={onRefresh}
            tintColor={Colors.white}
          />
        }
        ListEmptyComponent={!isLoading ? renderEmpty : null}
      />
    </SafeAreaView>
  );
};

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
    marginBottom: 4,
  },
  subtitle: {
    fontSize: 14,
    color: Colors.grey500,
  },
  listContent: {
    padding: 20,
  },
  dateHeader: {
    paddingVertical: 12,
  },
  dateHeaderText: {
    fontSize: 14,
    fontWeight: '600',
    color: Colors.grey500,
    letterSpacing: 0.5,
    textTransform: 'uppercase',
  },
  logCard: {
    marginBottom: 12,
  },
  logHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginBottom: 8,
  },
  logTime: {
    fontSize: 12,
    color: Colors.grey500,
  },
  voiceIndicator: {
    fontSize: 16,
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
    paddingVertical: 60,
  },
  emptyTitle: {
    fontSize: 20,
    fontWeight: '600',
    color: Colors.grey400,
    marginBottom: 8,
  },
  emptyText: {
    fontSize: 14,
    color: Colors.grey600,
    textAlign: 'center',
  },
});
