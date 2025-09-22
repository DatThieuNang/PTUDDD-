import '../repositories/repositories.dart';

class RemoveFromCart {
  final CartRepository repo;
  RemoveFromCart(this.repo);
  Future<void> call(String bookId) async {
    final current = await repo.getCart();
    final next = current.where((e) => e.book.id != bookId).toList();
    await repo.setCart(next);
  }
}
