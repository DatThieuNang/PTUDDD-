import '../entities/entities.dart';
import '../repositories/repositories.dart';

class PlaceOrder {
  final OrderRepository orderRepo;
  final CartRepository cartRepo;
  PlaceOrder(this.orderRepo, this.cartRepo);

  Future<void> call(List<CartItem> items, int total) async {
    final order = Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      items: items,
      total: total,
      createdAt: DateTime.now(),
    );
    await orderRepo.addOrder(order);
    await cartRepo.setCart([]); // clear sau khi đặt
  }
}
