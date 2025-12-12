/**
 * Insights Screen - View statistics and patterns
 */

import React, { useEffect, useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  SafeAreaView,
  ScrollView,
  RefreshControl,
} from 'react-native';
import { Colors } from '../../constants/colors';
import { Card } from '../../components/common/Card';
import { InsightsCharts } from '../../components/insights/InsightsCharts';
import { useInsightsStore } from '../../store/insightsStore';
import { format } from 'date-fns';

export const InsightsScreen: React.FC = () => {
  const { dailyInsight, currentStreak, fetchDailyInsight, fetchStreakData, refreshAll } = useInsightsStore();
  const [refreshing, setRefreshing] = useState(false);

  useEffect(() => {
    refreshAll();
  }, []);

  const onRefresh = async () => {
    setRefreshing(true);
    await refreshAll();
    setRefreshing(false);
  };

  // Get data from insight
  const totalLogs = dailyInsight?.data.totalLogs || 0;
  const categorizedLogs = dailyInsight?.data.topActivities.reduce((sum, act) => sum + act.count, 0) || 0;
  const voiceLogs = 0; // TODO: Track in insights
  const completionRate = dailyInsight?.data.completionRate || 0;

  // Get top categories from insights
  const topCategories = dailyInsight?.data.topActivities || [];

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.title}>Insights</Text>
        <Text style={styles.subtitle}>{format(new Date(), 'MMMM d, yyyy')}</Text>
      </View>

      <ScrollView
        style={styles.scrollView}
        contentContainerStyle={styles.scrollContent}
        refreshControl={
          <RefreshControl
            refreshing={refreshing}
            onRefresh={onRefresh}
            tintColor={Colors.white}
          />
        }
      >
        <View style={styles.statsGrid}>
          <StatCard title="Total Logs" value={totalLogs.toString()} />
          <StatCard title="Categorized" value={categorizedLogs.toString()} />
          <StatCard title="Completion" value={`${Math.round(completionRate * 100)}%`} />
          <StatCard title="Streak" value={`${currentStreak} day${currentStreak !== 1 ? 's' : ''}`} />
        </View>

        {topCategories.length > 0 && (
          <Card style={styles.section}>
            <Text style={styles.sectionTitle}>Top Activities</Text>
            {topCategories.map((activity) => (
              <View key={activity.activity} style={styles.activityRow}>
                <Text style={styles.activityName}>{activity.activity}</Text>
                <View style={styles.activityBar}>
                  <View
                    style={[
                      styles.activityBarFill,
                      { width: `${(activity.count / totalLogs) * 100}%` },
                    ]}
                  />
                  <Text style={styles.activityCount}>{activity.count}</Text>
                </View>
              </View>
            ))}
          </Card>
        )}

        {/* Advanced Charts */}
        {totalLogs > 0 && (
          <InsightsCharts dailyInsight={dailyInsight} />
        )}

        {totalLogs === 0 && (
          <View style={styles.emptyState}>
            <Text style={styles.emptyTitle}>No data yet</Text>
            <Text style={styles.emptyText}>
              Start logging your activities to see insights and visualizations
            </Text>
          </View>
        )}
      </ScrollView>
    </SafeAreaView>
  );
};

interface StatCardProps {
  title: string;
  value: string;
}

const StatCard: React.FC<StatCardProps> = ({ title, value }) => (
  <Card style={styles.statCard}>
    <Text style={styles.statValue}>{value}</Text>
    <Text style={styles.statTitle}>{title}</Text>
  </Card>
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
    marginBottom: 4,
  },
  subtitle: {
    fontSize: 14,
    color: Colors.grey500,
  },
  scrollView: {
    flex: 1,
  },
  scrollContent: {
    padding: 20,
  },
  statsGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 12,
    marginBottom: 20,
  },
  statCard: {
    flex: 1,
    minWidth: '47%',
    alignItems: 'center',
    paddingVertical: 20,
  },
  statValue: {
    fontSize: 32,
    fontWeight: '700',
    color: Colors.white,
    marginBottom: 8,
  },
  statTitle: {
    fontSize: 12,
    color: Colors.grey500,
    textTransform: 'uppercase',
    letterSpacing: 0.5,
  },
  section: {
    marginBottom: 20,
  },
  sectionTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: Colors.grey400,
    marginBottom: 16,
  },
  activityRow: {
    marginBottom: 16,
  },
  activityName: {
    fontSize: 14,
    color: Colors.white,
    marginBottom: 8,
    fontWeight: '500',
  },
  activityBar: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
  },
  activityBarFill: {
    height: 8,
    backgroundColor: Colors.white,
    borderRadius: 4,
    minWidth: 20,
  },
  activityCount: {
    fontSize: 14,
    color: Colors.grey400,
    fontFamily: 'monospace',
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
