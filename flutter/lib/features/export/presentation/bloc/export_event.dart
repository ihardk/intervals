import 'package:freezed_annotation/freezed_annotation.dart';

part 'export_event.freezed.dart';

@freezed
class ExportEvent with _$ExportEvent {
  const factory ExportEvent.exportToCsv({
    required String startDate,
    required String endDate,
  }) = ExportToCsv;

  const factory ExportEvent.exportToJson({
    required String startDate,
    required String endDate,
  }) = ExportToJson;
}
