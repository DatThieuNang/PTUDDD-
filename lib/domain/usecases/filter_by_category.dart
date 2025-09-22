import '../entities/entities.dart';
import '../repositories/repositories.dart';

class FilterByCategory {
  final BookRepository repo;
  FilterByCategory(this.repo);
  Future<List<Book>> call(String? category) async {
    final all = await repo.listAll();
    if (category == null || category.isEmpty) return all;
    return all.where((b) => b.category.toLowerCase() == category.toLowerCase()).toList();
  }
}
