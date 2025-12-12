/**
 * History Screen - View all logged activities
 */

import React, { useEffect, useState, useMemo } from 'react';
import {
  View,
  Text,
  StyleSheet,

  FlatList,
  RefreshControl,
  TouchableOpacity,
  Alert,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Colors } from '../../constants/colors';
import { Card } from '../../components/common/Card';
import { TextInput } from '../../components/common/TextInput';
import { SwipeableRow } from '../../components/common/SwipeableRow';
import { EditLogModal } from '../../components/modals/EditLogModal';
import { CalendarView } from '../../components/calendar/CalendarView';
import { SkeletonList } from '../../components/common/SkeletonLoader';
import { Toast, ToastType } from '../../components/common/Toast';
import { FadeInView } from '../../components/common/FadeInView';
import { useLogsStore } from '../../store/logsStore';
import { format, isToday, isYesterday, startOfDay } from 'date-fns';
import type { Log } from '../../models/Log';

type ViewMode = 'list' | 'calendar';

export const HistoryScreen: React.FC = () => {
  const { logs, fetchTodayLogs, deleteLog, updateLog, isLoading } = useLogsStore();
  const [refreshing, setRefreshing] = useState(false);
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedCategory, setSelectedCategory] = useState<string | null>(null);
  const [editModalVisible, setEditModalVisible] = useState(false);
  const [editingLog, setEditingLog] = useState<Log | null>(null);
  const [viewMode, setViewMode] = useState<ViewMode>('list');
  const [selectedDate, setSelectedDate] = useState<Date | undefined>();
  const [calendarFilteredLogs, setCalendarFilteredLogs] = useState<Log[]>([]);
  const [toastVisible, setToastVisible] = useState(false);
  const [toastMessage, setToastMessage] = useState('');
  const [toastType, setToastType] = useState<ToastType>('success');

  useEffect(() => {
    fetchTodayLogs();
  }, []);

  const onRefresh = async () => {
    setRefreshing(true);
    await fetchTodayLogs();
    setRefreshing(false);
  };

  // Filter logs based on search and category
  const filteredLogs = useMemo(() => {
    let filtered = logs;

    // Search filter
    if (searchQuery.trim()) {
      const query = searchQuery.toLowerCase();
      filtered = filtered.filter((log) =>
        log.content.toLowerCase().includes(query) ||
        log.category?.toLowerCase().includes(query)
      );
    }

    // Category filter
    if (selectedCategory) {
      filtered = filtered.filter((log) => log.category === selectedCategory);
    }

    return filtered;
  }, [logs, searchQuery, selectedCategory]);

  // Get unique categories
  const categories = useMemo(() => {
    const cats = new Set(logs.map((log) => log.category).filter(Boolean));
    return Array.from(cats) as string[];
  }, [logs]);

  const showToast = (message: string, type: ToastType = 'success') => {
    setToastMessage(message);
    setToastType(type);
    setToastVisible(true);
  };

  const handleDeleteLog = (log: Log) => {
    Alert.alert(
      'Delete Log',
      'Are you sure you want to delete this log?',
      [
        { text: 'Cancel', style: 'cancel' },
        {
          text: 'Delete',
          style: 'destructive',
          onPress: async () => {
            try {
              await deleteLog(log.id);
              showToast('Log deleted successfully', 'success');
            } catch (error) {
              showToast('Failed to delete log', 'error');
            }
          },
        },
      ]
    );
  };

  const handleEditLog = (log: Log) => {
    setEditingLog(log);
    setEditModalVisible(true);
  };

  const handleSaveLog = async (logId: string, content: string, category?: string) => {
    try {
      await updateLog({ id: logId, content, category });
      setEditModalVisible(false);
      setEditingLog(null);
      showToast('Log updated successfully', 'success');
    } catch (error) {
      console.error('Failed to update log:', error);
      showToast('Failed to update log', 'error');
      throw error;
    }
  };

  const handleCloseModal = () => {
    setEditModalVisible(false);
    setEditingLog(null);
  };

  const handleCalendarDateSelect = (date: Date, logsForDay: Log[]) => {
    setSelectedDate(date);
    setCalendarFilteredLogs(logsForDay);
  };

  const handleToggleViewMode = () => {
    setViewMode((prev) => (prev === 'list' ? 'calendar' : 'list'));
    // Reset filters when switching views
    if (viewMode === 'calendar') {
      setSelectedDate(undefined);
      setCalendarFilteredLogs([]);
    }
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
        startOfDay(displayLogs[index - 1].timestamp).getTime();

    return (
      <FadeInView delay={index * 50} duration={300}>
        {showDateHeader && renderDateHeader(new Date(item.timestamp))}
        <SwipeableRow
          onEdit={() => handleEditLog(item)}
          onDelete={() => handleDeleteLog(item)}
        >
          <Card style={styles.logCard}>
            <View style={styles.logHeader}>
              <Text style={styles.logTime}>{format(new Date(item.timestamp), 'h:mm a')}</Text>
              {item.entryType === 'voice' && (
                <Text style={styles.voiceIndicator}>🎤 Voice</Text>
              )}
            </View>
            <Text style={styles.logContent}>{item.content}</Text>
            {item.category && (
              <TouchableOpacity
                onPress={() => setSelectedCategory(selectedCategory === item.category ? null : item.category!)}
                style={[
                  styles.categoryBadge,
                  selectedCategory === item.category && styles.categoryBadgeActive,
                ]}
              >
                <Text style={styles.categoryText}>{item.category}</Text>
              </TouchableOpacity>
            )}
          </Card>
        </SwipeableRow>
      </FadeInView>
    );
  };

  const renderEmpty = () => (
    <View style={styles.emptyState}>
      <Text style={styles.emptyTitle}>
        {searchQuery || selectedCategory ? 'No logs match your search' : 'No logs yet'}
      </Text>
      <Text style={styles.emptyText}>
        {searchQuery || selectedCategory
          ? 'Try adjusting your search or filters'
          : 'Start logging your activities to build your history'}
      </Text>
      {(searchQuery || selectedCategory) && (
        <TouchableOpacity
          onPress={() => {
            setSearchQuery('');
            setSelectedCategory(null);
          }}
          style={styles.clearButton}
        >
          <Text style={styles.clearButtonText}>Clear filters</Text>
        </TouchableOpacity>
      )}
    </View>
  );

  // Use calendar filtered logs if in calendar mode with a selected date
  const displayLogs = viewMode === 'calendar' && selectedDate ? calendarFilteredLogs : filteredLogs;

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <View style={styles.headerTop}>
          <View>
            <Text style={styles.title}>History</Text>
            <Text style={styles.subtitle}>
              {displayLogs.length} of {logs.length} logs
              {selectedCategory && ` · ${selectedCategory}`}
              {selectedDate && ` · ${format(selectedDate, 'MMM d')}`}
            </Text>
          </View>
          <TouchableOpacity onPress={handleToggleViewMode} style={styles.viewToggle}>
            <Text style={styles.viewToggleText}>{viewMode === 'list' ? '📅' : '📋'}</Text>
          </TouchableOpacity>
        </View>
      </View>

      {viewMode === 'list' ? (
        <>
          <View style={styles.searchSection}>
            <TextInput
              value={searchQuery}
              onChangeText={setSearchQuery}
              placeholder="Search logs..."
              style={styles.searchInput}
            />
            {(searchQuery || selectedCategory) && (
              <TouchableOpacity
                onPress={() => {
                  setSearchQuery('');
                  setSelectedCategory(null);
                }}
                style={styles.clearSearchButton}
              >
                <Text style={styles.clearSearchText}>Clear</Text>
              </TouchableOpacity>
            )}
          </View>

          {categories.length > 0 && (
            <View style={styles.categoriesSection}>
              <FlatList
                horizontal
                data={categories}
                keyExtractor={(item) => item}
                showsHorizontalScrollIndicator={false}
                contentContainerStyle={styles.categoriesList}
                renderItem={({ item }) => (
                  <TouchableOpacity
                    onPress={() => setSelectedCategory(selectedCategory === item ? null : item)}
                    style={[
                      styles.categoryFilterChip,
                      selectedCategory === item && styles.categoryFilterChipActive,
                    ]}
                  >
                    <Text
                      style={[
                        styles.categoryFilterText,
                        selectedCategory === item && styles.categoryFilterTextActive,
                      ]}
                    >
                      {item}
                    </Text>
                  </TouchableOpacity>
                )}
              />
            </View>
          )}

          {isLoading ? (
            <SkeletonList count={5} />
          ) : (
            <FlatList
              data={displayLogs}
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
              ListEmptyComponent={renderEmpty}
            />
          )}
        </>
      ) : (
        <View style={styles.calendarContent}>
          <View style={styles.calendarWrapper}>
            <CalendarView onDateSelected={handleCalendarDateSelect} selectedDate={selectedDate} />
          </View>

          {selectedDate && (
            <View style={styles.selectedDateSection}>
              <Text style={styles.selectedDateTitle}>
                {isToday(selectedDate)
                  ? 'Today'
                  : isYesterday(selectedDate)
                  ? 'Yesterday'
                  : format(selectedDate, 'MMMM d, yyyy')}
              </Text>
              <Text style={styles.selectedDateCount}>
                {calendarFilteredLogs.length} {calendarFilteredLogs.length === 1 ? 'log' : 'logs'}
              </Text>
            </View>
          )}

          {isLoading ? (
            <SkeletonList count={3} />
          ) : (
            <FlatList
              data={displayLogs}
              renderItem={renderLog}
              keyExtractor={(item) => item.id}
              contentContainerStyle={styles.listContent}
              ListEmptyComponent={
                selectedDate ? (
                  <View style={styles.emptyState}>
                    <Text style={styles.emptyTitle}>No logs for this date</Text>
                    <Text style={styles.emptyText}>Tap a date with activity to view logs</Text>
                  </View>
                ) : (
                  <View style={styles.emptyState}>
                    <Text style={styles.emptyTitle}>Select a date</Text>
                    <Text style={styles.emptyText}>Tap a date on the calendar to view logs</Text>
                  </View>
                )
              }
            />
          )}
        </View>
      )}

      {/* Edit Log Modal */}
      <EditLogModal
        visible={editModalVisible}
        log={editingLog}
        onClose={handleCloseModal}
        onSave={handleSaveLog}
        availableCategories={categories}
      />

      {/* Toast Notifications */}
      <Toast
        visible={toastVisible}
        message={toastMessage}
        type={toastType}
        onHide={() => setToastVisible(false)}
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
  headerTop: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    justifyContent: 'space-between',
  },
  viewToggle: {
    padding: 8,
    marginTop: 4,
  },
  viewToggleText: {
    fontSize: 24,
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
  searchSection: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 20,
    paddingVertical: 12,
    gap: 8,
  },
  searchInput: {
    flex: 1,
    minHeight: 44,
  },
  clearSearchButton: {
    paddingHorizontal: 12,
    paddingVertical: 8,
  },
  clearSearchText: {
    fontSize: 14,
    color: Colors.grey400,
    fontWeight: '500',
  },
  categoriesSection: {
    paddingBottom: 12,
  },
  categoriesList: {
    paddingHorizontal: 20,
    gap: 8,
  },
  categoryFilterChip: {
    paddingHorizontal: 16,
    paddingVertical: 8,
    borderRadius: 16,
    backgroundColor: Colors.grey900,
    borderWidth: 1,
    borderColor: Colors.grey700,
  },
  categoryFilterChipActive: {
    backgroundColor: Colors.white,
    borderColor: Colors.white,
  },
  categoryFilterText: {
    fontSize: 14,
    color: Colors.grey300,
    fontWeight: '500',
  },
  categoryFilterTextActive: {
    color: Colors.black,
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
  logActions: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
  },
  actionButton: {
    padding: 4,
  },
  actionText: {
    fontSize: 16,
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
  categoryBadgeActive: {
    backgroundColor: Colors.white,
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
    marginBottom: 20,
  },
  clearButton: {
    paddingHorizontal: 20,
    paddingVertical: 10,
    backgroundColor: Colors.grey900,
    borderRadius: 4,
    borderWidth: 1,
    borderColor: Colors.grey700,
  },
  clearButtonText: {
    fontSize: 14,
    color: Colors.grey300,
    fontWeight: '500',
  },
  calendarContent: {
    flex: 1,
  },
  calendarWrapper: {
    padding: 20,
  },
  selectedDateSection: {
    paddingHorizontal: 20,
    paddingVertical: 12,
    borderBottomWidth: 1,
    borderBottomColor: Colors.grey900,
  },
  selectedDateTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: Colors.white,
    marginBottom: 4,
  },
  selectedDateCount: {
    fontSize: 14,
    color: Colors.grey500,
  },
});
