import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/category_repository.dart';

class DeleteCategory {
  final CategoryRepository repository;

  DeleteCategory(this.repository);

  Future<Either<Failure, void>> call(String id) {
    return repository.deleteCategory(id);
  }
}
