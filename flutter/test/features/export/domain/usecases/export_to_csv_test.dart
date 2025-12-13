import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:interval/features/export/domain/repositories/export_repository.dart';
import 'package:interval/features/export/domain/usecases/export_to_csv.dart';

@GenerateMocks([ExportRepository])
import 'export_to_csv_test.mocks.dart';

void main() {
  late ExportToCSV usecase;
  late MockExportRepository mockExportRepository;

  setUp(() {
    mockExportRepository = MockExportRepository();
    usecase = ExportToCSV(mockExportRepository);
  });

  const tStartDate = '2025-01-01';
  const tEndDate = '2025-01-31';
  const tPath = '/path/to/export.csv';

  test(
    'should export to CSV via repository',
    () async {
      // Arrange
      when(mockExportRepository.exportToCSV(
        startDate: anyNamed('startDate'),
        endDate: anyNamed('endDate'),
      )).thenAnswer((_) async => const Right(tPath));

      // Act
      final result = await usecase(startDate: tStartDate, endDate: tEndDate);

      // Assert
      expect(result, const Right(tPath));
      verify(mockExportRepository.exportToCSV(
        startDate: tStartDate,
        endDate: tEndDate,
      ));
      verifyNoMoreInteractions(mockExportRepository);
    },
  );
}
