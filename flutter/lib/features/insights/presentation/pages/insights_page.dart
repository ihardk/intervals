import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/colors.dart';
import '../../../../shared/widgets/app_card.dart';
import '../bloc/insights_bloc.dart';
import '../bloc/insights_event.dart';
import '../bloc/insights_state.dart';

class InsightsPage extends StatelessWidget {
  const InsightsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          GetIt.I<InsightsBloc>()..add(const InsightsEvent.loadInsights()),
      child: const InsightsView(),
    );
  }
}

class InsightsView extends StatelessWidget {
  const InsightsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Insights',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('MMMM d, yyyy').format(DateTime.now()),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.grey4,
                ),
              ),
              const SizedBox(height: 24),

              BlocBuilder<InsightsBloc, InsightsState>(
                builder: (context, state) {
                  return state.when(
                    initial: () => const SizedBox.shrink(),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (msg) => Center(
                        child: Text('Error: $msg',
                            style: const TextStyle(color: AppColors.white))),
                    loaded: (insight, topActivities, completionRate) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Stats Grid
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 1.5,
                            children: [
                              _StatCard(
                                title: 'TOTAL LOGS',
                                value: insight.data.totalLogs.toString(),
                              ),
                              _StatCard(
                                title: 'CATEGORIZED',
                                value: insight.data.topActivities
                                    .fold<int>(
                                        0, (sum, item) => sum + item.count)
                                    .toString(),
                              ),
                              _StatCard(
                                title: 'COMPLETION',
                                value:
                                    '${(insight.data.completionRate * 100).toInt()}%',
                              ),
                              // Streak data
                              _StatCard(
                                title: 'STREAK',
                                value: insight.data.streakDays > 0
                                    ? '${insight.data.streakDays} ${insight.data.streakDays == 1 ? 'day' : 'days'}'
                                    : '-',
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),

                          // Top Activities Section
                          if (topActivities.isNotEmpty) ...[
                            const Text(
                              'TOP ACTIVITIES',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.grey4,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            AppCard(
                              child: Column(
                                children: topActivities.map((activity) {
                                  final percentage =
                                      activity.count / insight.data.totalLogs;
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              activity
                                                  .activity, // Using activity name as label for now (should be category)
                                              style: const TextStyle(
                                                color: AppColors.white,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Text(
                                              activity.count.toString(),
                                              style: const TextStyle(
                                                color: AppColors.grey4,
                                                fontFamily: 'monospace',
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          child: LinearProgressIndicator(
                                            value: percentage,
                                            backgroundColor: AppColors.grey2,
                                            valueColor:
                                                const AlwaysStoppedAnimation<
                                                    Color>(AppColors.white),
                                            minHeight: 6,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],

                          const SizedBox(height: 32),
                          const Text(
                            'WEEKLY ACTIVITY',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.grey4,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 200,
                            child: BarChart(
                              BarChartData(
                                gridData: const FlGridData(show: false),
                                borderData: FlBorderData(show: false),
                                titlesData: FlTitlesData(
                                  show: true,
                                  topTitles: AxisTitles(
                                      sideTitles:
                                          SideTitles(showTitles: false)),
                                  leftTitles: AxisTitles(
                                      sideTitles:
                                          SideTitles(showTitles: false)),
                                  rightTitles: AxisTitles(
                                      sideTitles:
                                          SideTitles(showTitles: false)),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        if (value < 0 || value > 6) {
                                          return const SizedBox.shrink();
                                        }
                                        // Calculate actual date for this bar
                                        // Bar 0 = 6 days ago, Bar 6 = today
                                        final insightDate =
                                            DateTime.parse(insight.date);
                                        final daysAgo = 6 - value.toInt();
                                        final barDate = insightDate
                                            .subtract(Duration(days: daysAgo));

                                        // weekday: 1=Mon, 2=Tue, ..., 7=Sun
                                        final dayNames = [
                                          'Mon',
                                          'Tue',
                                          'Wed',
                                          'Thu',
                                          'Fri',
                                          'Sat',
                                          'Sun'
                                        ];
                                        final dayName =
                                            dayNames[(barDate.weekday - 1) % 7];

                                        return SideTitleWidget(
                                          axisSide: meta.axisSide,
                                          child: Text(
                                            '$dayName ${barDate.day}',
                                            style: const TextStyle(
                                              color: AppColors.grey4,
                                              fontSize: 10,
                                            ),
                                          ),
                                        );
                                      },
                                      reservedSize: 30,
                                    ),
                                  ),
                                ),
                                barGroups: [
                                  // Use real weekly activity data (reversed to show oldest to newest left-to-right)
                                  ...List.generate(
                                    insight.data.weeklyActivity.length,
                                    (index) {
                                      // weeklyActivity: [0] = today, [6] = 6 days ago
                                      // Chart wants: [0] = 6 days ago, [6] = today
                                      final reversedIndex =
                                          insight.data.weeklyActivity.length -
                                              1 -
                                              index;
                                      return _makeGroupData(
                                        index,
                                        insight
                                            .data.weeklyActivity[reversedIndex]
                                            .toDouble(),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _bottomTitles(double value, TitleMeta meta) {
    const style = TextStyle(color: AppColors.grey4, fontSize: 10);
    String text;
    switch (value.toInt()) {
      case 0:
        text = 'M';
        break;
      case 1:
        text = 'T';
        break;
      case 2:
        text = 'W';
        break;
      case 3:
        text = 'T';
        break;
      case 4:
        text = 'F';
        break;
      case 5:
        text = 'S';
        break;
      case 6:
        text = 'S';
        break;
      default:
        text = '';
    }
    return SideTitleWidget(
        axisSide: meta.axisSide, child: Text(text, style: style));
  }

  static BarChartGroupData _makeGroupData(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: AppColors.white,
          width: 16,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;

  const _StatCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.grey4,
              letterSpacing: 0.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
