import '../repositories/repositories.dart';

class ToggleWishlist {
  final WishlistRepository repo;
  ToggleWishlist(this.repo);
  Future<List<String>> call(String bookId) async {
    final ids = await repo.getWishlistIds();
    if (ids.contains(bookId)) {
      ids.remove(bookId);
    } else {
      ids.add(bookId);
    }
    await repo.setWishlistIds(ids);
    return ids;
  }
}
