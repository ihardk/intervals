import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/exports_table.dart';

part 'exports_dao.g.dart';

/// Data Access Object for Exports table
/// Manages data export history
@DriftAccessor(tables: [Exports])
class ExportsDao extends DatabaseAccessor<AppDatabase> with _$ExportsDaoMixin {
  ExportsDao(super.db);

  /// Get an export by ID
  Future<ExportData?> getExportById(String id) {
    return (select(exports)..where((e) => e.id.equals(id))).getSingleOrNull();
  }

  /// Get all exports
  Future<List<ExportData>> getAllExports() {
    return (select(exports)..orderBy([(e) => OrderingTerm.desc(e.createdAt)])).get();
  }

  /// Get exports by type
  Future<List<ExportData>> getExportsByType(String exportType) {
    return (select(exports)
          ..where((e) => e.exportType.equals(exportType))
          ..orderBy([(e) => OrderingTerm.desc(e.createdAt)]))
        .get();
  }

  /// Get recent exports
  Future<List<ExportData>> getRecentExports({int limit = 10}) {
    return (select(exports)
          ..orderBy([(e) => OrderingTerm.desc(e.createdAt)])
          ..limit(limit))
        .get();
  }

  /// Get exports for a date range
  Future<List<ExportData>> getExportsByDateRange(String startDate, String endDate) {
    return (select(exports)
          ..where((e) => e.dateRangeStart.isBiggerOrEqualValue(startDate))
          ..where((e) => e.dateRangeEnd.isSmallerOrEqualValue(endDate))
          ..orderBy([(e) => OrderingTerm.desc(e.createdAt)]))
        .get();
  }

  /// Get total exported records count
  Future<int> getTotalExportedRecords() async {
    final allExports = await getAllExports();
    return allExports.fold<int>(
      0,
      (sum, export) => sum + (export.recordCount ?? 0),
    );
  }

  /// Get total export file size
  Future<int> getTotalExportSize() async {
    final allExports = await getAllExports();
    return allExports.fold<int>(
      0,
      (sum, export) => sum + (export.fileSize ?? 0),
    );
  }

  /// Insert a new export record
  Future<int> insertExport(ExportsCompanion export) {
    return into(exports).insert(export);
  }

  /// Update an export record
  Future<bool> updateExport(ExportData export) {
    return update(exports).replace(export);
  }

  /// Delete an export record
  Future<int> deleteExport(String id) {
    return (delete(exports)..where((e) => e.id.equals(id))).go();
  }

  /// Delete all exports
  Future<int> deleteAllExports() {
    return delete(exports).go();
  }

  /// Delete exports older than specified days
  Future<int> deleteOldExports(int olderThanDays) {
    final cutoffTime = DateTime.now()
        .subtract(Duration(days: olderThanDays))
        .millisecondsSinceEpoch;

    return (delete(exports)
          ..where((e) => e.createdAt.isSmallerThanValue(cutoffTime)))
        .go();
  }

  /// Get exports count
  Future<int> getExportsCount() async {
    final countExp = exports.id.count();
    final query = selectOnly(exports)..addColumns([countExp]);
    final result = await query.getSingle();
    return result.read(countExp) ?? 0;
  }

  /// Get exports count by type
  Future<int> getExportsCountByType(String exportType) async {
    final countExp = exports.id.count();
    final query = selectOnly(exports)
      ..addColumns([countExp])
      ..where(exports.exportType.equals(exportType));
    final result = await query.getSingle();
    return result.read(countExp) ?? 0;
  }

  /// Watch all exports
  Stream<List<ExportData>> watchAllExports() {
    return (select(exports)..orderBy([(e) => OrderingTerm.desc(e.createdAt)])).watch();
  }

  /// Watch recent exports
  Stream<List<ExportData>> watchRecentExports({int limit = 10}) {
    return (select(exports)
          ..orderBy([(e) => OrderingTerm.desc(e.createdAt)])
          ..limit(limit))
        .watch();
  }

  /// Watch exports by type
  Stream<List<ExportData>> watchExportsByType(String exportType) {
    return (select(exports)
          ..where((e) => e.exportType.equals(exportType))
          ..orderBy([(e) => OrderingTerm.desc(e.createdAt)]))
        .watch();
  }
}
