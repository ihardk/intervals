import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:interval/core/errors/failures.dart';
import 'package:interval/features/export/domain/usecases/export_to_csv.dart';
import 'package:interval/features/export/domain/usecases/export_to_json.dart';
import 'package:interval/features/export/presentation/bloc/export_bloc.dart';
import 'package:interval/features/export/presentation/bloc/export_event.dart';
import 'package:interval/features/export/presentation/bloc/export_state.dart';

@GenerateMocks([ExportToCSV, ExportToJSON])
import 'export_bloc_test.mocks.dart';

void main() {
  late ExportBloc bloc;
  late MockExportToCSV mockExportToCSV;
  late MockExportToJSON mockExportToJSON;

  setUp(() {
    mockExportToCSV = MockExportToCSV();
    mockExportToJSON = MockExportToJSON();
    bloc = ExportBloc(
      exportToCSV: mockExportToCSV,
      exportToJSON: mockExportToJSON,
    );
  });

  const tStartDate = '2023-01-01';
  const tEndDate = '2023-01-31';
  const tFilePath = '/path/to/file.csv';

  test('initial state is ExportInitial', () {
    expect(bloc.state, const ExportState.initial());
  });

  group('ExportToCsv', () {
    blocTest<ExportBloc, ExportState>(
      'emits [ExportLoading, ExportSuccess] when successful',
      build: () {
        when(mockExportToCSV(
                startDate: anyNamed('startDate'), endDate: anyNamed('endDate')))
            .thenAnswer((_) async => const Right(tFilePath));
        return bloc;
      },
      act: (bloc) => bloc.add(const ExportEvent.exportToCsv(
        startDate: tStartDate,
        endDate: tEndDate,
      )),
      expect: () => [
        const ExportState.loading(),
        const ExportState.success(tFilePath),
      ],
      verify: (_) {
        verify(mockExportToCSV(startDate: tStartDate, endDate: tEndDate));
      },
    );

    blocTest<ExportBloc, ExportState>(
      'emits [ExportLoading, ExportError] when failure',
      build: () {
        when(mockExportToCSV(
                startDate: anyNamed('startDate'), endDate: anyNamed('endDate')))
            .thenAnswer((_) async => const Left(CacheFailure('Error')));
        return bloc;
      },
      act: (bloc) => bloc.add(const ExportEvent.exportToCsv(
        startDate: tStartDate,
        endDate: tEndDate,
      )),
      expect: () => [
        const ExportState.loading(),
        const ExportState.error('Error'),
      ],
    );
  });
}
