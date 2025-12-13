import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:interval/features/insights/domain/entities/insight.dart';
import 'package:interval/features/insights/domain/repositories/insight_repository.dart';
import 'package:interval/features/insights/domain/usecases/calculate_completion_rate.dart';

@GenerateMocks([InsightRepository])
import 'calculate_completion_rate_test.mocks.dart';

void main() {
  late CalculateCompletionRate usecase;
  late MockInsightRepository mockInsightRepository;

  setUp(() {
    mockInsightRepository = MockInsightRepository();
    usecase = CalculateCompletionRate(mockInsightRepository);
  });

  final tDate = DateTime(2025, 12, 13);
  const tRate = 0.85;
  final tInsight = Insight(
    id: '1',
    insightType: InsightType.daily,
    date: '2025-12-13',
    data: const InsightData(
      totalLogs: 10,
      completionRate: tRate,
    ),
    createdAt: DateTime.now().millisecondsSinceEpoch,
  );

  test(
    'should return completion rate from generated insight',
    () async {
      // Arrange
      when(mockInsightRepository.generateDailyInsight(any))
          .thenAnswer((_) async => Right(tInsight));

      // Act
      final result = await usecase(tDate);

      // Assert
      expect(result, const Right(tRate));
      verify(mockInsightRepository.generateDailyInsight(tDate));
      verifyNoMoreInteractions(mockInsightRepository);
    },
  );
}
