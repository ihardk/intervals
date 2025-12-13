import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/daos/logs_dao.dart';
import '../../../../core/database/daos/categories_dao.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/log.dart' as domain;
import '../../domain/repositories/log_repository.dart';

/// Implementation of LogRepository
/// Handles log data operations with auto-categorization
class LogRepositoryImpl implements LogRepository {
  final LogsDao logsDao;
  final CategoriesDao categoriesDao;

  LogRepositoryImpl({
    required this.logsDao,
    required this.categoriesDao,
  });

  @override
  Future<Either<Failure, domain.Log>> createLog({
    required String content,
    required String entryType,
    String? audioPath,
    String? category,
    List<String>? tags,
    String? mood,
    int? timestamp,
  }) async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final logId = const Uuid().v4();

      // Auto-categorize if category not provided
      String? finalCategory = category;
      if (finalCategory == null && content.isNotEmpty) {
        finalCategory = await _categorizeContent(content);
      }

      final logCompanion = LogsCompanion.insert(
        id: logId,
        timestamp: timestamp ?? now,
        content: content,
        entryType: entryType,
        audioPath: Value(audioPath),
        transcriptionStatus: const Value('complete'),
        category: Value(finalCategory),
        tags: Value(tags != null ? jsonEncode(tags) : null),
        mood: Value(mood),
        createdAt: now,
        updatedAt: now,
        isDeleted: const Value(0),
        metadata: const Value(null),
      );

      await logsDao.insertLog(logCompanion);
      final logData = await logsDao.getLogById(logId);

      if (logData == null) {
        return const Left(DatabaseFailure('Failed to retrieve created log'));
      }

      return Right(_mapToDomain(logData));
    } catch (e) {
      return Left(DatabaseFailure('Failed to create log: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<domain.Log>>> getTodayLogs() async {
    try {
      final logsData = await logsDao.getTodayLogs();
      final logs = logsData.map(_mapToDomain).toList();
      return Right(logs);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get today logs: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, domain.Log>> getLogById(String id) async {
    try {
      final logData = await logsDao.getLogById(id);

      if (logData == null) {
        return Left(NotFoundFailure('Log not found with id: $id'));
      }

      return Right(_mapToDomain(logData));
    } catch (e) {
      return Left(DatabaseFailure('Failed to get log: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<domain.Log>>> getLogsByDateRange({
    required int startTimestamp,
    required int endTimestamp,
  }) async {
    try {
      final logsData = await logsDao.getLogsByDateRange(
        startTimestamp,
        endTimestamp,
      );
      final logs = logsData.map(_mapToDomain).toList();
      return Right(logs);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get logs by date range: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<domain.Log>>> getLogsByCategory(String category) async {
    try {
      final logsData = await logsDao.getLogsByCategory(category);
      final logs = logsData.map(_mapToDomain).toList();
      return Right(logs);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get logs by category: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<domain.Log>>> searchLogs(String query) async {
    try {
      final logsData = await logsDao.searchLogs(query);
      final logs = logsData.map(_mapToDomain).toList();
      return Right(logs);
    } catch (e) {
      return Left(DatabaseFailure('Failed to search logs: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> updateLog(domain.Log log) async {
    try {
      final logData = _mapToData(log);
      await logsDao.updateLog(logData);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to update log: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteLog(String id) async {
    try {
      await logsDao.softDeleteLog(id);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete log: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, int>> getLogsCount() async {
    try {
      final count = await logsDao.getLogsCount();
      return Right(count);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get logs count: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, int>> getLogsCountByDateRange({
    required int startTimestamp,
    required int endTimestamp,
  }) async {
    try {
      final logs = await logsDao.getLogsByDateRange(
        startTimestamp,
        endTimestamp,
      );
      return Right(logs.length);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get logs count by date range: ${e.toString()}'));
    }
  }

  @override
  Stream<Either<Failure, List<domain.Log>>> watchTodayLogs() {
    try {
      return logsDao.watchTodayLogs().map(
        (logsData) => Right(logsData.map(_mapToDomain).toList()),
      );
    } catch (e) {
      return Stream.value(
        Left(DatabaseFailure('Failed to watch today logs: ${e.toString()}')),
      );
    }
  }

  /// Auto-categorize content based on keywords
  Future<String?> _categorizeContent(String content) async {
    try {
      final categories = await categoriesDao.getAllCategories();
      final lowerContent = content.toLowerCase();

      for (final category in categories) {
        final keywords = jsonDecode(category.keywords) as List<dynamic>;

        for (final keyword in keywords) {
          if (lowerContent.contains(keyword.toString().toLowerCase())) {
            return category.id;
          }
        }
      }

      return null; // No matching category
    } catch (e) {
      // If categorization fails, just return null
      return null;
    }
  }

  /// Map Drift LogData to domain Log entity
  domain.Log _mapToDomain(LogData data) {
    List<String> tagsList = [];
    if (data.tags != null) {
      try {
        final decoded = jsonDecode(data.tags!) as List<dynamic>;
        tagsList = decoded.map((e) => e.toString()).toList();
      } catch (e) {
        tagsList = [];
      }
    }

    Map<String, dynamic>? metadataMap;
    if (data.metadata != null) {
      try {
        metadataMap = jsonDecode(data.metadata!) as Map<String, dynamic>;
      } catch (e) {
        metadataMap = null;
      }
    }

    return domain.Log(
      id: data.id,
      timestamp: data.timestamp,
      content: data.content,
      entryType: _stringToEntryType(data.entryType),
      audioPath: data.audioPath,
      transcriptionStatus: _stringToTranscriptionStatus(data.transcriptionStatus),
      category: data.category,
      tags: tagsList,
      mood: data.mood,
      isDeleted: data.isDeleted == 1,
      metadata: metadataMap,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    );
  }

  /// Map domain Log entity to Drift LogData
  LogData _mapToData(domain.Log log) {
    return LogData(
      id: log.id,
      timestamp: log.timestamp,
      content: log.content,
      entryType: _entryTypeToString(log.entryType),
      audioPath: log.audioPath,
      transcriptionStatus: _transcriptionStatusToString(log.transcriptionStatus),
      category: log.category,
      tags: log.tags.isNotEmpty ? jsonEncode(log.tags) : null,
      mood: log.mood,
      createdAt: log.createdAt,
      updatedAt: log.updatedAt,
      isDeleted: log.isDeleted ? 1 : 0,
      metadata: log.metadata != null ? jsonEncode(log.metadata) : null,
    );
  }

  /// Convert string to EntryType enum
  domain.EntryType _stringToEntryType(String value) {
    switch (value) {
      case 'text':
        return domain.EntryType.text;
      case 'voice':
        return domain.EntryType.voice;
      case 'manual':
        return domain.EntryType.manual;
      default:
        return domain.EntryType.text;
    }
  }

  /// Convert EntryType enum to string
  String _entryTypeToString(domain.EntryType type) {
    switch (type) {
      case domain.EntryType.text:
        return 'text';
      case domain.EntryType.voice:
        return 'voice';
      case domain.EntryType.manual:
        return 'manual';
    }
  }

  /// Convert string to TranscriptionStatus enum
  domain.TranscriptionStatus _stringToTranscriptionStatus(String value) {
    switch (value) {
      case 'pending':
        return domain.TranscriptionStatus.pending;
      case 'complete':
        return domain.TranscriptionStatus.complete;
      case 'failed':
        return domain.TranscriptionStatus.failed;
      default:
        return domain.TranscriptionStatus.complete;
    }
  }

  /// Convert TranscriptionStatus enum to string
  String _transcriptionStatusToString(domain.TranscriptionStatus status) {
    switch (status) {
      case domain.TranscriptionStatus.pending:
        return 'pending';
      case domain.TranscriptionStatus.complete:
        return 'complete';
      case domain.TranscriptionStatus.failed:
        return 'failed';
    }
  }
}
