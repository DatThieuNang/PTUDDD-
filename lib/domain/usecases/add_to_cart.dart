import '../entities/entities.dart';
import '../repositories/repositories.dart';

class AddToCart {
  final CartRepository repo;
  AddToCart(this.repo);

  Future<void> call(CartItem item) async {
    final current = await repo.getCart();
    final idx = current.indexWhere((e) => e.book.id == item.book.id);
    if (idx >= 0) {
      final updated = current[idx].copyWith(qty: current[idx].qty + item.qty);
      current[idx] = updated;
    } else {
      current.add(item);
    }
    await repo.setCart(current);
  }
}
