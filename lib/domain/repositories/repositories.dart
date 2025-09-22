import '../entities/entities.dart';

abstract class BookRepository {
  Future<List<Book>> search(String query);
  Future<List<Book>> listAll();
  Future<Book?> getById(String id);
}

abstract class CartRepository {
  Future<List<CartItem>> getCart();
  Future<void> setCart(List<CartItem> items);
}

abstract class WishlistRepository {
  Future<List<String>> getWishlistIds();
  Future<void> setWishlistIds(List<String> ids);
}

abstract class OrderRepository {
  Future<List<Order>> getOrders();
  Future<void> addOrder(Order order);
}
