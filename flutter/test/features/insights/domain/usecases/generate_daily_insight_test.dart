import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:interval/features/insights/domain/entities/insight.dart';
import 'package:interval/features/insights/domain/repositories/insight_repository.dart';
import 'package:interval/features/insights/domain/usecases/generate_daily_insight.dart';

@GenerateMocks([InsightRepository])
import 'generate_daily_insight_test.mocks.dart';

void main() {
  late GenerateDailyInsight usecase;
  late MockInsightRepository mockInsightRepository;

  setUp(() {
    mockInsightRepository = MockInsightRepository();
    usecase = GenerateDailyInsight(mockInsightRepository);
  });

  final tDate = DateTime(2025, 12, 13);
  final tInsight = Insight(
    id: '1',
    insightType: InsightType.daily,
    date: '2025-12-13',
    data: const InsightData(totalLogs: 10),
    createdAt: DateTime.now().millisecondsSinceEpoch,
  );

  test(
    'should generate daily insight via repository',
    () async {
      // Arrange
      when(mockInsightRepository.generateDailyInsight(any))
          .thenAnswer((_) async => Right(tInsight));

      // Act
      final result = await usecase(tDate);

      // Assert
      expect(result, Right(tInsight));
      verify(mockInsightRepository.generateDailyInsight(tDate));
      verifyNoMoreInteractions(mockInsightRepository);
    },
  );
}
