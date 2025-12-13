import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/category_repository.dart';

class CategorizeLog {
  final CategoryRepository repository;

  CategorizeLog(this.repository);

  Future<Either<Failure, String?>> call(String content) {
    return repository.categorizeContent(content);
  }
}
