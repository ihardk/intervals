import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:interval/core/errors/failures.dart';
import 'package:interval/features/insights/domain/entities/insight.dart';
import 'package:interval/features/insights/domain/usecases/generate_daily_insight.dart';
import 'package:interval/features/insights/domain/usecases/get_top_activities.dart';
import 'package:interval/features/insights/domain/usecases/calculate_completion_rate.dart';
import 'package:interval/features/insights/presentation/bloc/insights_bloc.dart';
import 'package:interval/features/insights/presentation/bloc/insights_event.dart';
import 'package:interval/features/insights/presentation/bloc/insights_state.dart';
@GenerateMocks(
    [GenerateDailyInsight, GetTopActivities, CalculateCompletionRate])
import 'insights_bloc_test.mocks.dart';

void main() {
  late InsightsBloc bloc;
  late MockGenerateDailyInsight mockGenerateDailyInsight;
  late MockGetTopActivities mockGetTopActivities;
  late MockCalculateCompletionRate mockCalculateCompletionRate;

  setUp(() {
    mockGenerateDailyInsight = MockGenerateDailyInsight();
    mockGetTopActivities = MockGetTopActivities();
    mockCalculateCompletionRate = MockCalculateCompletionRate();
    bloc = InsightsBloc(
      generateDailyInsight: mockGenerateDailyInsight,
      getTopActivities: mockGetTopActivities,
      calculateCompletionRate: mockCalculateCompletionRate,
    );
  });

  final tTopActivities = [
    const ActivityCount(activity: 'Coding', count: 5),
    const ActivityCount(activity: 'Reading', count: 3),
  ];
  const tInsightData = InsightData(
    totalLogs: 10,
    completionRate: 0.8,
    topActivities: [
      ActivityCount(activity: 'Coding', count: 5),
      ActivityCount(activity: 'Reading', count: 3),
    ],
  );
  const tInsight = Insight(
    id: '1',
    insightType: InsightType.daily,
    date: '2025-01-01',
    data: tInsightData,
    createdAt: 12345678,
  );

  const tCompletionRate = 0.8;

  test('initial state is InsightsInitial', () {
    expect(bloc.state, const InsightsState.initial());
  });

  blocTest<InsightsBloc, InsightsState>(
    'emits [InsightsLoading, InsightsLoaded] when LoadInsights is added and all usecases succeed',
    build: () {
      when(mockGenerateDailyInsight(any))
          .thenAnswer((_) async => const Right(tInsight));
      when(mockGetTopActivities(any))
          .thenAnswer((_) async => Right(tTopActivities));
      when(mockCalculateCompletionRate(any))
          .thenAnswer((_) async => const Right(tCompletionRate));
      return bloc;
    },
    act: (bloc) => bloc.add(const InsightsEvent.loadInsights()),
    expect: () => [
      const InsightsState.loading(),
      InsightsState.loaded(
        dailyInsight: tInsight,
        topActivities: tTopActivities,
        completionRate: tCompletionRate,
      ),
    ],
    verify: (_) {
      verify(mockGenerateDailyInsight(any));
      verify(mockGetTopActivities(any));
      verify(mockCalculateCompletionRate(any));
    },
  );

  blocTest<InsightsBloc, InsightsState>(
    'emits [InsightsLoading, InsightsError] when one usecase fails',
    build: () {
      when(mockGenerateDailyInsight(any))
          .thenAnswer((_) async => const Left(CacheFailure('Error')));
      when(mockGetTopActivities(any))
          .thenAnswer((_) async => Right(tTopActivities));
      when(mockCalculateCompletionRate(any))
          .thenAnswer((_) async => const Right(tCompletionRate));
      return bloc;
    },
    act: (bloc) => bloc.add(const InsightsEvent.loadInsights()),
    expect: () => [
      const InsightsState.loading(),
      const InsightsState.error('Error'),
    ],
  );
}
