import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:interval/features/insights/domain/entities/insight.dart';
import 'package:interval/features/insights/domain/repositories/insight_repository.dart';
import 'package:interval/features/insights/domain/usecases/get_top_activities.dart';

@GenerateMocks([InsightRepository])
import 'get_top_activities_test.mocks.dart';

void main() {
  late GetTopActivities usecase;
  late MockInsightRepository mockInsightRepository;

  setUp(() {
    mockInsightRepository = MockInsightRepository();
    usecase = GetTopActivities(mockInsightRepository);
  });

  final tDate = DateTime(2025, 12, 13);
  final tActivities = [
    const ActivityCount(activity: 'Coding', count: 5),
    const ActivityCount(activity: 'Reading', count: 3),
  ];
  final tInsight = Insight(
    id: '1',
    insightType: InsightType.daily,
    date: '2025-12-13',
    data: InsightData(
      totalLogs: 8,
      topActivities: tActivities,
    ),
    createdAt: DateTime.now().millisecondsSinceEpoch,
  );

  test(
    'should return top activities from generated insight',
    () async {
      // Arrange
      when(mockInsightRepository.generateDailyInsight(any))
          .thenAnswer((_) async => Right(tInsight));

      // Act
      final result = await usecase(tDate);

      // Assert
      expect(result, Right(tActivities));
      verify(mockInsightRepository.generateDailyInsight(tDate));
      verifyNoMoreInteractions(mockInsightRepository);
    },
  );
}
