/**
 * InsightsCharts Component
 * Displays data visualizations for user insights
 */

import React from 'react';
import { View, Text, StyleSheet, Dimensions } from 'react-native';
import {
  VictoryBar,
  VictoryChart,
  VictoryTheme,
  VictoryAxis,
  VictoryLine,
  VictoryPie,
  VictoryLabel,
} from 'victory-native';
import { Colors } from '../../constants/colors';
import { Card } from '../common/Card';
import type { DailyInsight } from '../../models/Insight';

const SCREEN_WIDTH = Dimensions.get('window').width;
const CHART_WIDTH = SCREEN_WIDTH - 80; // Account for padding

interface InsightsChartsProps {
  dailyInsight?: DailyInsight | null;
  weeklyData?: Array<{ date: string; count: number }>;
}

export const InsightsCharts: React.FC<InsightsChartsProps> = ({
  dailyInsight,
  weeklyData,
}) => {
  // Prepare data for peak hours chart
  const peakHoursData = dailyInsight?.data?.peakHours?.map((hour) => ({
    x: `${hour}:00`,
    y: Math.random() * 10 + 5, // TODO: Use actual log count per hour
    label: `${hour}h`,
  })) || [];

  // Prepare data for category distribution
  const categoryData = dailyInsight?.data?.topActivities?.map((activity, index) => ({
    x: activity,
    y: Math.random() * 100 + 20, // TODO: Use actual category counts
    label: activity,
  })) || [];

  // Prepare data for completion rate over time (mock weekly data)
  const completionData = weeklyData || [
    { x: 'Mon', y: 75 },
    { x: 'Tue', y: 80 },
    { x: 'Wed', y: 65 },
    { x: 'Thu', y: 90 },
    { x: 'Fri', y: 85 },
    { x: 'Sat', y: 70 },
    { x: 'Sun', y: 60 },
  ];

  return (
    <View style={styles.container}>
      {/* Peak Hours Bar Chart */}
      {peakHoursData.length > 0 && (
        <Card style={styles.chartCard}>
          <Text style={styles.chartTitle}>Peak Activity Hours</Text>
          <Text style={styles.chartSubtitle}>When you're most active</Text>
          <VictoryChart
            width={CHART_WIDTH}
            height={220}
            theme={VictoryTheme.material}
            domainPadding={{ x: 20 }}
          >
            <VictoryAxis
              style={{
                axis: { stroke: Colors.grey700 },
                ticks: { stroke: Colors.grey700 },
                tickLabels: { fill: Colors.grey500, fontSize: 10 },
              }}
            />
            <VictoryAxis
              dependentAxis
              style={{
                axis: { stroke: Colors.grey700 },
                ticks: { stroke: Colors.grey700 },
                tickLabels: { fill: Colors.grey500, fontSize: 10 },
                grid: { stroke: Colors.grey900 },
              }}
            />
            <VictoryBar
              data={peakHoursData}
              style={{
                data: { fill: Colors.white },
              }}
              barWidth={16}
            />
          </VictoryChart>
        </Card>
      )}

      {/* Completion Rate Line Chart */}
      <Card style={styles.chartCard}>
        <Text style={styles.chartTitle}>Weekly Completion Rate</Text>
        <Text style={styles.chartSubtitle}>% of intervals logged</Text>
        <VictoryChart
          width={CHART_WIDTH}
          height={220}
          theme={VictoryTheme.material}
        >
          <VictoryAxis
            style={{
              axis: { stroke: Colors.grey700 },
              ticks: { stroke: Colors.grey700 },
              tickLabels: { fill: Colors.grey500, fontSize: 10 },
            }}
          />
          <VictoryAxis
            dependentAxis
            style={{
              axis: { stroke: Colors.grey700 },
              ticks: { stroke: Colors.grey700 },
              tickLabels: { fill: Colors.grey500, fontSize: 10 },
              grid: { stroke: Colors.grey900 },
            }}
          />
          <VictoryLine
            data={completionData}
            style={{
              data: { stroke: Colors.white, strokeWidth: 2 },
            }}
          />
        </VictoryChart>
      </Card>

      {/* Category Distribution Pie Chart */}
      {categoryData.length > 0 && (
        <Card style={styles.chartCard}>
          <Text style={styles.chartTitle}>Activity Distribution</Text>
          <Text style={styles.chartSubtitle}>Time spent per category</Text>
          <View style={styles.pieContainer}>
            <VictoryPie
              data={categoryData}
              width={CHART_WIDTH}
              height={280}
              colorScale={[
                Colors.white,
                Colors.grey300,
                Colors.grey500,
                Colors.grey600,
                Colors.grey700,
              ]}
              labelRadius={({ innerRadius }) => (innerRadius as number) + 40}
              style={{
                labels: { fill: Colors.black, fontSize: 12, fontWeight: 'bold' },
              }}
              labelComponent={<VictoryLabel />}
            />
          </View>
          {/* Legend */}
          <View style={styles.legend}>
            {categoryData.map((item, index) => (
              <View key={index} style={styles.legendItem}>
                <View
                  style={[
                    styles.legendColor,
                    {
                      backgroundColor: [
                        Colors.white,
                        Colors.grey300,
                        Colors.grey500,
                        Colors.grey600,
                        Colors.grey700,
                      ][index % 5],
                    },
                  ]}
                />
                <Text style={styles.legendText}>{item.label}</Text>
              </View>
            ))}
          </View>
        </Card>
      )}

      {/* Productivity Score Gauge (simplified) */}
      {dailyInsight?.data?.productivityScore !== undefined && (
        <Card style={styles.chartCard}>
          <Text style={styles.chartTitle}>Productivity Score</Text>
          <Text style={styles.chartSubtitle}>Today's productivity rating</Text>
          <View style={styles.scoreContainer}>
            <View style={styles.scoreCircle}>
              <Text style={styles.scoreValue}>
                {Math.round(dailyInsight.data.productivityScore * 100)}
              </Text>
              <Text style={styles.scoreLabel}>/ 100</Text>
            </View>
            <View style={styles.scoreBar}>
              <View
                style={[
                  styles.scoreBarFill,
                  { width: `${dailyInsight.data.productivityScore * 100}%` },
                ]}
              />
            </View>
          </View>
        </Card>
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    gap: 20,
  },
  chartCard: {
    padding: 16,
  },
  chartTitle: {
    fontSize: 18,
    fontWeight: '600',
    color: Colors.white,
    marginBottom: 4,
  },
  chartSubtitle: {
    fontSize: 14,
    color: Colors.grey500,
    marginBottom: 16,
  },
  pieContainer: {
    alignItems: 'center',
  },
  legend: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 12,
    marginTop: 16,
  },
  legendItem: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 6,
  },
  legendColor: {
    width: 12,
    height: 12,
    borderRadius: 2,
  },
  legendText: {
    fontSize: 12,
    color: Colors.grey400,
  },
  scoreContainer: {
    alignItems: 'center',
    paddingVertical: 20,
  },
  scoreCircle: {
    width: 120,
    height: 120,
    borderRadius: 60,
    backgroundColor: Colors.grey900,
    borderWidth: 8,
    borderColor: Colors.white,
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: 24,
  },
  scoreValue: {
    fontSize: 36,
    fontWeight: '700',
    color: Colors.white,
  },
  scoreLabel: {
    fontSize: 14,
    color: Colors.grey500,
  },
  scoreBar: {
    width: '100%',
    height: 8,
    backgroundColor: Colors.grey900,
    borderRadius: 4,
    overflow: 'hidden',
  },
  scoreBarFill: {
    height: '100%',
    backgroundColor: Colors.white,
    borderRadius: 4,
  },
});
