import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/log.dart';
import '../repositories/log_repository.dart';

/// Use case for creating a new log
/// Follows Single Responsibility Principle
class CreateLog {
  final LogRepository repository;

  CreateLog(this.repository);

  Future<Either<Failure, Log>> call({
    required String content,
    required EntryType entryType,
    String? audioPath,
    String? category,
    List<String>? tags,
    String? mood,
    int? timestamp,
  }) {
    return repository.createLog(
      content: content,
      entryType: entryType,
      audioPath: audioPath,
      category: category,
      tags: tags,
      mood: mood,
      timestamp: timestamp,
    );
  }
}
