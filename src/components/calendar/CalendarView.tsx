/**
 * CalendarView Component
 * Activity heatmap calendar with date selection
 */

import React, { useMemo, useState, useEffect } from 'react';
import { View, Text, StyleSheet, ActivityIndicator } from 'react-native';
import { Calendar, DateData } from 'react-native-calendars';
import { Colors } from '../../constants/colors';
import { startOfMonth, endOfMonth, format, startOfDay } from 'date-fns';
import { logService } from '../../services/logs/LogService';
import type { Log } from '../../models/Log';

interface CalendarViewProps {
  onDateSelected?: (date: Date, logs: Log[]) => void;
  selectedDate?: Date;
}

export const CalendarView: React.FC<CalendarViewProps> = ({
  onDateSelected,
  selectedDate,
}) => {
  const [currentMonth, setCurrentMonth] = useState(new Date());
  const [logs, setLogs] = useState<Log[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    loadLogsForMonth(currentMonth);
  }, [currentMonth]);

  const loadLogsForMonth = async (month: Date) => {
    setIsLoading(true);
    try {
      const start = startOfMonth(month);
      const end = endOfMonth(month);
      const monthLogs = await logService.getLogsByDateRange(start, end);
      setLogs(monthLogs);
    } catch (error) {
      console.error('Failed to load calendar logs:', error);
    } finally {
      setIsLoading(false);
    }
  };

  // Group logs by date and count
  const logsByDate = useMemo(() => {
    const grouped: Record<string, Log[]> = {};

    logs.forEach((log) => {
      const dateKey = format(new Date(log.timestamp), 'yyyy-MM-dd');
      if (!grouped[dateKey]) {
        grouped[dateKey] = [];
      }
      grouped[dateKey].push(log);
    });

    return grouped;
  }, [logs]);

  // Generate marked dates with heatmap colors
  const markedDates = useMemo(() => {
    const marked: any = {};

    Object.entries(logsByDate).forEach(([dateStr, dateLogs]) => {
      const count = dateLogs.length;

      // Heatmap color intensity based on log count
      let color = Colors.grey900; // 0 logs (won't appear)
      if (count >= 10) {
        color = Colors.white; // 10+ logs - brightest
      } else if (count >= 6) {
        color = Colors.grey300; // 6-9 logs
      } else if (count >= 3) {
        color = Colors.grey500; // 3-5 logs
      } else if (count >= 1) {
        color = Colors.grey700; // 1-2 logs
      }

      marked[dateStr] = {
        marked: true,
        dotColor: color,
        selected: false,
      };
    });

    // Mark selected date
    if (selectedDate) {
      const selectedDateStr = format(startOfDay(selectedDate), 'yyyy-MM-dd');
      marked[selectedDateStr] = {
        ...marked[selectedDateStr],
        selected: true,
        selectedColor: Colors.white,
        selectedTextColor: Colors.black,
      };
    }

    return marked;
  }, [logsByDate, selectedDate]);

  const handleDayPress = (day: DateData) => {
    const date = new Date(day.timestamp);
    const dateKey = format(date, 'yyyy-MM-dd');
    const logsForDay = logsByDate[dateKey] || [];

    onDateSelected?.(date, logsForDay);
  };

  const handleMonthChange = (month: DateData) => {
    const newMonth = new Date(month.timestamp);
    setCurrentMonth(newMonth);
  };

  return (
    <View style={styles.container}>
      {isLoading ? (
        <View style={styles.loadingContainer}>
          <ActivityIndicator size="small" color={Colors.white} />
        </View>
      ) : (
        <>
          <Calendar
            current={format(currentMonth, 'yyyy-MM-dd')}
            onDayPress={handleDayPress}
            onMonthChange={handleMonthChange}
            markedDates={markedDates}
            theme={{
              calendarBackground: Colors.black,
              textSectionTitleColor: Colors.grey500,
              selectedDayBackgroundColor: Colors.white,
              selectedDayTextColor: Colors.black,
              todayTextColor: Colors.white,
              dayTextColor: Colors.grey300,
              textDisabledColor: Colors.grey800,
              dotColor: Colors.white,
              selectedDotColor: Colors.black,
              arrowColor: Colors.white,
              monthTextColor: Colors.white,
              indicatorColor: Colors.white,
              textDayFontFamily: 'System',
              textMonthFontFamily: 'System',
              textDayHeaderFontFamily: 'System',
              textDayFontWeight: '400',
              textMonthFontWeight: '600',
              textDayHeaderFontWeight: '500',
              textDayFontSize: 14,
              textMonthFontSize: 16,
              textDayHeaderFontSize: 12,
            }}
            style={styles.calendar}
          />

          {/* Heatmap Legend */}
          <View style={styles.legend}>
            <Text style={styles.legendLabel}>Activity:</Text>
            <View style={styles.legendItems}>
              <View style={styles.legendItem}>
                <View style={[styles.legendDot, { backgroundColor: Colors.grey700 }]} />
                <Text style={styles.legendText}>1-2</Text>
              </View>
              <View style={styles.legendItem}>
                <View style={[styles.legendDot, { backgroundColor: Colors.grey500 }]} />
                <Text style={styles.legendText}>3-5</Text>
              </View>
              <View style={styles.legendItem}>
                <View style={[styles.legendDot, { backgroundColor: Colors.grey300 }]} />
                <Text style={styles.legendText}>6-9</Text>
              </View>
              <View style={styles.legendItem}>
                <View style={[styles.legendDot, { backgroundColor: Colors.white }]} />
                <Text style={styles.legendText}>10+</Text>
              </View>
            </View>
          </View>
        </>
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    backgroundColor: Colors.black,
  },
  loadingContainer: {
    paddingVertical: 40,
    alignItems: 'center',
  },
  calendar: {
    borderRadius: 8,
    backgroundColor: Colors.black,
    borderWidth: 1,
    borderColor: Colors.grey900,
  },
  legend: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingTop: 16,
    paddingHorizontal: 4,
  },
  legendLabel: {
    fontSize: 12,
    color: Colors.grey500,
    fontWeight: '500',
    textTransform: 'uppercase',
    letterSpacing: 0.5,
  },
  legendItems: {
    flexDirection: 'row',
    gap: 12,
  },
  legendItem: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
  },
  legendDot: {
    width: 8,
    height: 8,
    borderRadius: 4,
  },
  legendText: {
    fontSize: 11,
    color: Colors.grey400,
  },
});
