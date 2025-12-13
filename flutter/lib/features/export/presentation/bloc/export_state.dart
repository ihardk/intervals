import 'package:freezed_annotation/freezed_annotation.dart';

part 'export_state.freezed.dart';

@freezed
class ExportState with _$ExportState {
  const factory ExportState.initial() = ExportInitial;
  const factory ExportState.loading() = ExportLoading;
  const factory ExportState.success(String filePath) = ExportSuccess;
  const factory ExportState.error(String message) = ExportError;
}
