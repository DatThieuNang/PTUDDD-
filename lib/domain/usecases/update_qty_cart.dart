import '../repositories/repositories.dart';

class UpdateQtyCart {
  final CartRepository repo;
  UpdateQtyCart(this.repo);
  Future<void> call(String bookId, int qty) async {
    var items = await repo.getCart();
    final i = items.indexWhere((e) => e.book.id == bookId);
    if (i >= 0) {
      if (qty <= 0) {
        items.removeAt(i);
      } else {
        items[i] = items[i].copyWith(qty: qty);
      }
      await repo.setCart(items);
    }
  }
}
