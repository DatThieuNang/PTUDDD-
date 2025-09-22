import '../entities/entities.dart';
import '../repositories/repositories.dart';

class GetBookDetail {
  final BookRepository repo;
  GetBookDetail(this.repo);
  Future<Book?> call(String id) => repo.getById(id);
}
