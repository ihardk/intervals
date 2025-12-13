import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/category.dart';
import '../repositories/category_repository.dart';

class CreateCategory {
  final CategoryRepository repository;

  CreateCategory(this.repository);

  Future<Either<Failure, Category>> call({
    required String name,
    required List<String> keywords,
    String? color,
    String? icon,
  }) {
    return repository.createCategory(
      name: name,
      keywords: keywords,
      color: color,
      icon: icon,
    );
  }
}
