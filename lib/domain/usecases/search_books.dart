import '../entities/entities.dart';
import '../repositories/repositories.dart';

class SearchBooks {
  final BookRepository repo;
  SearchBooks(this.repo);
  Future<List<Book>> call(String query) => repo.search(query);
}
