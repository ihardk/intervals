import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/export_to_csv.dart';
import '../../domain/usecases/export_to_json.dart';
import 'export_event.dart';
import 'export_state.dart';

class ExportBloc extends Bloc<ExportEvent, ExportState> {
  final ExportToCSV exportToCSV;
  final ExportToJSON exportToJSON;

  ExportBloc({
    required this.exportToCSV,
    required this.exportToJSON,
  }) : super(const ExportState.initial()) {
    on<ExportToCsv>(_onExportToCsv);
    on<ExportToJson>(_onExportToJson);
  }

  Future<void> _onExportToCsv(
    ExportToCsv event,
    Emitter<ExportState> emit,
  ) async {
    emit(const ExportState.loading());
    final result = await exportToCSV(
      startDate: event.startDate,
      endDate: event.endDate,
    );
    emit(result.fold(
      (failure) => ExportState.error(failure.message),
      (filePath) => ExportState.success(filePath),
    ));
  }

  Future<void> _onExportToJson(
    ExportToJson event,
    Emitter<ExportState> emit,
  ) async {
    emit(const ExportState.loading());
    final result = await exportToJSON(
      startDate: event.startDate,
      endDate: event.endDate,
    );
    emit(result.fold(
      (failure) => ExportState.error(failure.message),
      (filePath) => ExportState.success(filePath),
    ));
  }
}
