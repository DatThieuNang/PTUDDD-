import '../../domain/entities/entities.dart';
import '../../domain/repositories/repositories.dart';
import '../datasources/memory.dart';

class BookRepositoryImpl implements BookRepository {
  final MemoryDataSource ds;
  BookRepositoryImpl(this.ds);

  @override
  Future<List<Book>> listAll() async => ds.catalog;

  @override
  Future<Book?> getById(String id) async {
    final idx = ds.catalog.indexWhere((b) => b.id == id);
    if (idx == -1) return null;
    return ds.catalog[idx];
  }

  @override
  Future<List<Book>> search(String query) async {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return ds.catalog;
    return ds.catalog.where((b) =>
      b.title.toLowerCase().contains(q) ||
      b.author.toLowerCase().contains(q) ||
      b.category.toLowerCase().contains(q)
    ).toList();
  }
}

class CartRepositoryImpl implements CartRepository {
  final MemoryDataSource ds;
  CartRepositoryImpl(this.ds);

  @override
  Future<List<CartItem>> getCart() => ds.loadCart();

  @override
  Future<void> setCart(List<CartItem> items) => ds.saveCart(items);
}

class WishlistRepositoryImpl implements WishlistRepository {
  final MemoryDataSource ds;
  WishlistRepositoryImpl(this.ds);

  @override
  Future<List<String>> getWishlistIds() => ds.loadWishlistIds();

  @override
  Future<void> setWishlistIds(List<String> ids) => ds.saveWishlistIds(ids);
}

class OrderRepositoryImpl implements OrderRepository {
  final MemoryDataSource ds;
  OrderRepositoryImpl(this.ds);

  @override
  Future<List<Order>> getOrders() => ds.loadOrders();

  @override
  Future<void> addOrder(Order order) async {
    final list = await ds.loadOrders();
    list.add(order);
    await ds.saveOrders(list);
  }
}
