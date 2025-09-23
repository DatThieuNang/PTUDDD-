import "dart:math";
import "package:flutter/material.dart";
import "../../data/datasources/memory.dart";
import "../../domain/entities/entities.dart";

/// Sort dùng cho Tab Catalog
enum SortType { popular, newest, priceAsc, priceDesc, rating }

class AppState extends ChangeNotifier {
  final MemoryDataSource ds;
  AppState(this.ds);

  // ---------- Catalog / filter / sort ----------
  String _query = "";
  String _category = ""; // rỗng = tất cả
  SortType sortType = SortType.popular;

  List<Book> get catalog => ds.catalog;
  String? get currentCategory => _category.isEmpty ? null : _category;

  void doSearch(String q) { _query = q.trim(); notifyListeners(); }
  void applyCategory(String cat) { _category = cat; notifyListeners(); }
  void setSort(SortType t) { sortType = t; notifyListeners(); }

  List<Book> get catalogView {
    var list = catalog.where((b) {
      final okCat = _category.isEmpty || b.category == _category;
      if (_query.isEmpty) return okCat;
      final q = _query.toLowerCase();
      final okQ = b.title.toLowerCase().contains(q)
        || b.author.toLowerCase().contains(q)
        || b.category.toLowerCase().contains(q);
      return okCat && okQ;
    }).toList();

    switch (sortType) {
      case SortType.popular:
        list.sort((a,b) => b.soldCount.compareTo(a.soldCount));
        break;
      case SortType.newest:
        // publishedAt là nullable -> dùng mốc tối thiểu khi null
        final minDt = DateTime.fromMillisecondsSinceEpoch(0);
        list.sort((a,b) => (b.publishedAt ?? minDt).compareTo(a.publishedAt ?? minDt));
        break;
      case SortType.priceAsc:
        list.sort((a,b) => a.salePrice.compareTo(b.salePrice));
        break;
      case SortType.priceDesc:
        list.sort((a,b) => b.salePrice.compareTo(a.salePrice));
        break;
      case SortType.rating:
        list.sort((a,b) => b.ratingAvg.compareTo(a.ratingAvg));
        break;
    }
    return list;
  }

  // ---------- Cart ----------
  final List<CartItem> _cart = [];
  List<CartItem> get cart => List.unmodifiable(_cart);

  int get cartSubtotal => _cart.fold(0, (s, it) => s + it.book.salePrice * it.qty);
  int get subtotal => cartSubtotal; // alias cho file cũ

  void addOne(Book b) {
    final i = _cart.indexWhere((e) => e.book.id == b.id);
    if (i == -1) {
      _cart.add(CartItem(book: b, qty: 1));
    } else {
      _cart[i] = _cart[i].copyWith(qty: _cart[i].qty + 1);
    }
    _persistCart();
    notifyListeners();
  }

  // API theo id (tương thích các file cũ)
  void incOne(String id) {
    final b = catalog.firstWhere((e) => e.id == id);
    addOne(b);
  }
  void decOne(String id) {
    final i = _cart.indexWhere((e) => e.book.id == id);
    if (i == -1) return;
    final q = _cart[i].qty - 1;
    if (q <= 0) _cart.removeAt(i);
    else _cart[i] = _cart[i].copyWith(qty: q);
    _persistCart();
    notifyListeners();
  }
  void removeItem(String id) {
    _cart.removeWhere((e) => e.book.id == id);
    _persistCart();
    notifyListeners();
  }
  void clearCart() {
    _cart.clear();
    _discount = 0; _couponCode = null;
    _persistCart();
    notifyListeners();
  }

  // ---------- Wishlist ----------
  final Set<String> _wish = {};
  Set<String> get wishlistIds => _wish;

  /// Nhận Book hoặc String id (tương thích mọi nơi gọi)
  void toggleWishlist(Object item) {
    final id = item is Book ? item.id : item as String;
    if (_wish.contains(id)) _wish.remove(id); else _wish.add(id);
    _persistWishlist();
    notifyListeners();
  }

  // ---------- Reviews ----------
  Future<double> getAverageRating(String bookId) async {
    final rs = await ds.loadReviews(bookId);
    if (rs.isEmpty) return 0;
    final sum = rs.map((e) => e.rating).reduce((a,b)=>a+b);
    return sum / rs.length;
  }

  Future<List<Review>> getReviews(String bookId) => ds.loadReviews(bookId);

  Future<void> addReview(String bookId, int rating, String text) async {
    final review = Review(rating: rating, text: text, createdAt: DateTime.now());
    await ds.addReview(bookId, review);
    notifyListeners();
  }

  // ---------- Coupon & Total ----------
  String? _couponCode;
  int _discount = 0;
  String? get couponCode => _couponCode;
  int get discount => _discount;
  int get cartTotal => max(0, cartSubtotal - _discount);

  String applyCoupon(String code) {
    final c = code.trim().toUpperCase();
    if (c.isEmpty) { _couponCode = null; _discount = 0; notifyListeners(); return "Đã xóa mã giảm giá."; }
    if (_cart.isEmpty) { return "Giỏ hàng trống."; }
    final sub = cartSubtotal;
    if (c == "FIT30") {
      _couponCode = c; _discount = min((sub * 0.30).round(), 50000); notifyListeners(); return "Áp dụng FIT30 thành công.";
    } else if (c == "NEW10") {
      _couponCode = c; _discount = (sub * 0.10).round(); notifyListeners(); return "Áp dụng NEW10 thành công.";
    } else { return "Mã không hợp lệ."; }
  }

  // ---------- Orders ----------
  final List<Order> _orders = [];
  List<Order> get orders => List.unmodifiable(_orders);

  Address? address;

  Future<void> loadPersisted() async {
    _cart..clear()..addAll(await ds.loadCart());
    _wish..clear()..addAll(await ds.loadWishlistIds());
    _orders..clear()..addAll(await ds.loadOrders());
    notifyListeners();
  }
  Future<void> _persistCart() async => ds.saveCart(_cart);
  Future<void> _persistWishlist() async => ds.saveWishlistIds(_wish.toList());
  Future<void> _persistOrders() async => ds.saveOrders(_orders);

  Future<Order?> placeCurrentOrder() async {
    if (_cart.isEmpty) return null;
    final o = Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      items: List<CartItem>.from(_cart),
      total: cartTotal,
      createdAt: DateTime.now(),
    );
    _orders.insert(0, o);
    await _persistOrders();
    clearCart();
    return o;
  }

  /// Mua lại từ một đơn cũ (OrdersPage gọi)
  Future<void> reOrder(Order o) async {
    _cart
      ..clear()
      ..addAll(o.items.map((e) => CartItem(book: e.book, qty: e.qty)));
    _discount = 0; _couponCode = null;
    await _persistCart();
    notifyListeners();
  }

  /// Mua ngay từ trang chi tiết
  Future<void> buyNow(Book b) async {
    clearCart();
    addOne(b);
  }
}
