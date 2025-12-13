import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/daos/exports_dao.dart';
import '../../../../core/database/daos/logs_dao.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/export_repository.dart';

/// Implementation of ExportRepository
/// Handles data export to CSV and JSON formats
class ExportRepositoryImpl implements ExportRepository {
  final ExportsDao exportsDao;
  final LogsDao logsDao;

  ExportRepositoryImpl({
    required this.exportsDao,
    required this.logsDao,
  });

  @override
  Future<Either<Failure, String>> exportToCSV({
    required String startDate,
    required String endDate,
  }) async {
    try {
      final startTimestamp = DateTime.parse(startDate).millisecondsSinceEpoch;
      final endTimestamp = DateTime.parse(endDate).millisecondsSinceEpoch;

      final logs = await logsDao.getLogsByDateRange(startTimestamp, endTimestamp);

      // Create CSV data
      final List<List<dynamic>> csvData = [
        ['ID', 'Timestamp', 'Content', 'Entry Type', 'Category', 'Tags', 'Mood', 'Created At'],
      ];

      for (final log in logs) {
        csvData.add([
          log.id,
          DateTime.fromMillisecondsSinceEpoch(log.timestamp).toIso8601String(),
          log.content,
          log.entryType,
          log.category ?? '',
          log.tags ?? '',
          log.mood ?? '',
          DateTime.fromMillisecondsSinceEpoch(log.createdAt).toIso8601String(),
        ]);
      }

      final csvString = const ListToCsvConverter().convert(csvData);

      // Save to file
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'logs_export_${DateTime.now().millisecondsSinceEpoch}.csv';
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      await file.writeAsString(csvString);

      // Save export record
      await _saveExportRecord(
        exportType: 'csv',
        filePath: filePath,
        dateRangeStart: startDate,
        dateRangeEnd: endDate,
        recordCount: logs.length,
        fileSize: await file.length(),
      );

      return Right(filePath);
    } catch (e) {
      return Left(FileSystemFailure('Failed to export to CSV: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, String>> exportToJSON({
    required String startDate,
    required String endDate,
  }) async {
    try {
      final startTimestamp = DateTime.parse(startDate).millisecondsSinceEpoch;
      final endTimestamp = DateTime.parse(endDate).millisecondsSinceEpoch;

      final logs = await logsDao.getLogsByDateRange(startTimestamp, endTimestamp);

      // Create JSON data
      final jsonData = logs.map((log) => {
        'id': log.id,
        'timestamp': DateTime.fromMillisecondsSinceEpoch(log.timestamp).toIso8601String(),
        'content': log.content,
        'entryType': log.entryType,
        'category': log.category,
        'tags': log.tags,
        'mood': log.mood,
        'createdAt': DateTime.fromMillisecondsSinceEpoch(log.createdAt).toIso8601String(),
        'updatedAt': DateTime.fromMillisecondsSinceEpoch(log.updatedAt).toIso8601String(),
      }).toList();

      final jsonString = const JsonEncoder.withIndent('  ').convert({
        'export_date': DateTime.now().toIso8601String(),
        'date_range': {
          'start': startDate,
          'end': endDate,
        },
        'logs_count': logs.length,
        'logs': jsonData,
      });

      // Save to file
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'logs_export_${DateTime.now().millisecondsSinceEpoch}.json';
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      await file.writeAsString(jsonString);

      // Save export record
      await _saveExportRecord(
        exportType: 'json',
        filePath: filePath,
        dateRangeStart: startDate,
        dateRangeEnd: endDate,
        recordCount: logs.length,
        fileSize: await file.length(),
      );

      return Right(filePath);
    } catch (e) {
      return Left(FileSystemFailure('Failed to export to JSON: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<ExportRecord>>> getExportHistory() async {
    try {
      final exportsData = await exportsDao.getAllExports();
      final exports = exportsData.map(_mapToDomain).toList();
      return Right(exports);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get export history: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<ExportRecord>>> getExportsByType(String type) async {
    try {
      final exportsData = await exportsDao.getExportsByType(type);
      final exports = exportsData.map(_mapToDomain).toList();
      return Right(exports);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get exports by type: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<ExportRecord>>> getRecentExports({int limit = 10}) async {
    try {
      final exportsData = await exportsDao.getRecentExports(limit: limit);
      final exports = exportsData.map(_mapToDomain).toList();
      return Right(exports);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get recent exports: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, int>> deleteOldExports(int olderThanDays) async {
    try {
      final count = await exportsDao.deleteOldExports(olderThanDays);
      return Right(count);
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete old exports: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteExport(String id) async {
    try {
      await exportsDao.deleteExport(id);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete export: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, int>> getTotalExportedRecords() async {
    try {
      final totalRecords = await exportsDao.getTotalExportedRecords();
      return Right(totalRecords);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get total exported records: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, int>> getTotalExportSize() async {
    try {
      final totalSize = await exportsDao.getTotalExportSize();
      return Right(totalSize);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get total export size: ${e.toString()}'));
    }
  }

  /// Save export record to database
  Future<void> _saveExportRecord({
    required String exportType,
    required String filePath,
    required String dateRangeStart,
    required String dateRangeEnd,
    required int recordCount,
    required int fileSize,
  }) async {
    final exportId = const Uuid().v4();
    final now = DateTime.now().millisecondsSinceEpoch;

    await exportsDao.insertExport(
      ExportsCompanion.insert(
        id: exportId,
        exportType: exportType,
        filePath: filePath,
        dateRangeStart: dateRangeStart,
        dateRangeEnd: dateRangeEnd,
        recordCount: Value(recordCount),
        fileSize: Value(fileSize),
        createdAt: now,
      ),
    );
  }

  /// Map Drift ExportData to domain ExportRecord
  ExportRecord _mapToDomain(ExportData data) {
    return ExportRecord(
      id: data.id,
      exportType: data.exportType,
      filePath: data.filePath,
      dateRangeStart: data.dateRangeStart,
      dateRangeEnd: data.dateRangeEnd,
      recordCount: data.recordCount,
      fileSize: data.fileSize,
      createdAt: data.createdAt,
    );
  }
}
