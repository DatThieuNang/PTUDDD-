import "dart:math";
import "dart:convert";
import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";

import "../../data/datasources/memory.dart";
import "../../domain/entities/entities.dart";

enum SortType { popular, newest, priceAsc, priceDesc, rating }

/// Mô phỏng phương thức & trạng thái thanh toán (metadata không đụng class Order)
enum OrderStatus { pending, paid, shipping, done }

/// ===== Notifications model (top-level) =====
class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool read;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    this.read = false,
  });

  AppNotification copyWith({bool? read}) => AppNotification(
        id: id,
        title: title,
        body: body,
        createdAt: createdAt,
        read: read ?? this.read,
      );
}

class AppState extends ChangeNotifier {
  final MemoryDataSource ds;
  AppState(this.ds);

  // ---------- Theme ----------
  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;

  /// Đặt theme và lưu SharedPreferences
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final sp = await SharedPreferences.getInstance();
    await sp.setString(
      "theme_mode",
      mode == ThemeMode.dark
          ? "dark"
          : (mode == ThemeMode.light ? "light" : "system"),
    );
  }

  /// Chuyển qua lại Light/Dark (và persist)
  Future<void> toggleTheme() async {
    final next =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await setThemeMode(next);
  }

  /// Wrapper để tương thích với SettingsPage cũ (nếu đang gọi hàm này)
  Future<void> toggleThemeAndPersist() => toggleTheme();

  // ---------- Catalog / filter / sort ----------
  String _query = "";
  String _category = "";
  SortType sortType = SortType.popular;
  bool showPromo = false, showBestseller = false, showNew = false;

  List<Book> get catalog => ds.catalog;
  String? get currentCategory => _category.isEmpty ? null : _category;

  void doSearch(String q) {
    _query = q.trim();
    notifyListeners();
  }

  void applyCategory(String cat) {
    _category = cat;
    notifyListeners();
  }

  void setSort(SortType t) {
    sortType = t;
    notifyListeners();
  }

  void togglePromo() {
    showPromo = !showPromo;
    notifyListeners();
  }

  void toggleBestseller() {
    showBestseller = !showBestseller;
    notifyListeners();
  }

  void toggleNew() {
    showNew = !showNew;
    notifyListeners();
  }

  List<Book> get catalogView {
    final now = DateTime.now();
    const recentDays = 120;
    var list = catalog.where((b) {
      final okCat = _category.isEmpty || b.category == _category;
      final q = _query.toLowerCase();
      final okQ = _query.isEmpty ||
          b.title.toLowerCase().contains(q) ||
          b.author.toLowerCase().contains(q) ||
          b.category.toLowerCase().contains(q);
      final okPromo = !showPromo || b.salePercent > 0;
      final okBest = !showBestseller || b.soldCount >= 1000;
      final okNew = !showNew ||
          (b.publishedAt != null &&
              now.difference(b.publishedAt!).inDays <= recentDays);
      return okCat && okQ && okPromo && okBest && okNew;
    }).toList();

    switch (sortType) {
      case SortType.popular:
        list.sort((a, b) => b.soldCount.compareTo(a.soldCount));
        break;
      case SortType.newest:
        final minDt = DateTime.fromMillisecondsSinceEpoch(0);
        list.sort((a, b) =>
            (b.publishedAt ?? minDt).compareTo(a.publishedAt ?? minDt));
        break;
      case SortType.priceAsc:
        list.sort((a, b) => a.salePrice.compareTo(b.salePrice));
        break;
      case SortType.priceDesc:
        list.sort((a, b) => b.salePrice.compareTo(a.salePrice));
        break;
      case SortType.rating:
        list.sort((a, b) => b.ratingAvg.compareTo(a.ratingAvg));
        break;
    }
    return list;
  }

  // ---------- Cart ----------
  final List<CartItem> _cart = [];
  List<CartItem> get cart => List.unmodifiable(_cart);
  int get cartSubtotal =>
      _cart.fold(0, (s, it) => s + it.book.salePrice * it.qty);
  int get subtotal => cartSubtotal; // alias cũ

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

  void incOne(String id) {
    final b = catalog.firstWhere((e) => e.id == id);
    addOne(b);
  }

  void decOne(String id) {
    final i = _cart.indexWhere((e) => e.book.id == id);
    if (i == -1) return;
    final q = _cart[i].qty - 1;
    if (q <= 0) {
      _cart.removeAt(i);
    } else {
      _cart[i] = _cart[i].copyWith(qty: q);
    }
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
    _discount = 0;
    _couponCode = null;
    _persistCart();
    notifyListeners();
  }

  // ---------- Wishlist ----------
  final Set<String> _wish = {};
  Set<String> get wishlistIds => _wish;
  void toggleWishlist(Object item) {
    final id = item is Book ? item.id : item as String;
    if (_wish.contains(id)) {
      _wish.remove(id);
    } else {
      _wish.add(id);
    }
    _persistWishlist();
    notifyListeners();
  }

  // ---------- Reviews ----------
  Future<double> getAverageRating(String bookId) async {
    final rs = await ds.loadReviews(bookId);
    if (rs.isEmpty) return 0;
    final sum = rs.map((e) => e.rating).reduce((a, b) => a + b);
    return sum / rs.length;
  }

  Future<List<Review>> getReviews(String bookId) => ds.loadReviews(bookId);

  Future<void> addReview(String bookId, int rating, String text) async {
    final review =
        Review(rating: rating, text: text, createdAt: DateTime.now());
    await ds.addReview(bookId, review);
    notifyListeners();
  }

  // ---------- Coupon ----------
  String? _couponCode;
  int _discount = 0;
  String? get couponCode => _couponCode;
  int get discount => _discount;

  String applyCoupon(String code) {
    final c = code.trim().toUpperCase();
    if (c.isEmpty) {
      _couponCode = null;
      _discount = 0;
      notifyListeners();
      return "Đã xóa mã giảm giá.";
    }
    if (_cart.isEmpty) return "Giỏ hàng trống.";
    final sub = cartSubtotal;
    if (c == "FIT30") {
      _couponCode = c;
      _discount = min((sub * 0.30).round(), 50000);
      notifyListeners();
      return "Áp dụng FIT30 thành công.";
    }
    if (c == "NEW10") {
      _couponCode = c;
      _discount = (sub * 0.10).round();
      notifyListeners();
      return "Áp dụng NEW10 thành công.";
    }
    return "Mã không hợp lệ.";
  }

  // ---------- Shipping (mô phỏng) ----------
  final List<Map<String, dynamic>> shippingOptions = const [
    {"code": "in_city", "label": "Nội thành", "fee": 15000},
    {"code": "out_city", "label": "Ngoại thành", "fee": 25000},
    {"code": "express", "label": "Hỏa tốc (Nội thành)", "fee": 40000},
  ];
  String _shippingCode = "in_city";
  int get shippingFee =>
      shippingOptions.firstWhere((e) => e["code"] == _shippingCode)["fee"]
          as int;
  String get shippingLabel =>
      shippingOptions.firstWhere((e) => e["code"] == _shippingCode)["label"]
          as String;

  void setShipping(String code) {
    _shippingCode = code;
    notifyListeners();
  }

  Address? address;

  // Tổng cuối cùng = tạm tính - giảm + ship
  int get grandTotal => max(0, cartSubtotal - _discount) + shippingFee;

  // ---------- Orders & meta ----------
  final List<Order> _orders = [];
  List<Order> get orders => List.unmodifiable(_orders);

  // meta trạng thái & phương thức (không đụng model Order)
  final Map<String, OrderStatus> _orderStatus = {};
  final Map<String, String> _orderMethod = {};

  Future<void> _persistOrderMeta() async {
    final sp = await SharedPreferences.getInstance();
    final st = _orderStatus.map((k, v) => MapEntry(k, v.index));
    await sp.setString("order_status_map", jsonEncode(st));
    await sp.setString("order_method_map", jsonEncode(_orderMethod));
  }

  Future<void> _loadOrderMeta() async {
    final sp = await SharedPreferences.getInstance();
    final sm = sp.getString("order_status_map");
    if (sm != null && sm.isNotEmpty) {
      final m = (jsonDecode(sm) as Map).map(
        (k, v) => MapEntry(k as String, OrderStatus.values[(v as num).toInt()]),
      );
      _orderStatus
        ..clear()
        ..addAll(m);
    }
    final mm = sp.getString("order_method_map");
    if (mm != null && mm.isNotEmpty) {
      final m2 = (jsonDecode(mm) as Map)
          .map((k, v) => MapEntry(k as String, v as String));
      _orderMethod
        ..clear()
        ..addAll(m2);
    }
  } // "COD"/"VNPay"/"MoMo"

  OrderStatus statusOf(String orderId) =>
      _orderStatus[orderId] ?? OrderStatus.paid;
  String methodOf(String orderId) => _orderMethod[orderId] ?? "COD";

  /// Nạp dữ liệu + theme + meta order
  Future<void> loadPersisted() async {
    _cart
      ..clear()
      ..addAll(await ds.loadCart());
    _wish
      ..clear()
      ..addAll(await ds.loadWishlistIds());
    _orders
      ..clear()
      ..addAll(await ds.loadOrders());

    // Load theme & order meta
    final sp = await SharedPreferences.getInstance();
    final tm = sp.getString("theme_mode");
    if (tm == "dark") _themeMode = ThemeMode.dark;
    if (tm == "light") _themeMode = ThemeMode.light;

    await _loadOrderMeta();
    notifyListeners();
  }

  Future<void> _persistCart() async => ds.saveCart(_cart);
  Future<void> _persistWishlist() async => ds.saveWishlistIds(_wish.toList());
  Future<void> _persistOrders() async => ds.saveOrders(_orders);

  /// Tạo đơn: total = grandTotal (đã gồm ship/giảm).
  /// method: "COD" | "VNPay" | "MoMo" ; status: pending (COD) / paid (cổng)
  Future<Order?> placeCurrentOrder({required String method}) async {
    if (_cart.isEmpty) return null;
    final o = Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      items: List<CartItem>.from(_cart),
      total: grandTotal,
      createdAt: DateTime.now(),
    );
    _orders.insert(0, o);
    _orderMethod[o.id] = method;
    _orderStatus[o.id] =
        method == "COD" ? OrderStatus.pending : OrderStatus.paid;

    await _persistOrders();
    await _persistOrderMeta();
    clearCart(); // reset giỏ + coupon
    return o;
  }

  Future<void> reOrder(Order o) async {
    _cart
      ..clear()
      ..addAll(o.items.map((e) => CartItem(book: e.book, qty: e.qty)));
    _discount = 0;
    _couponCode = null;
    await _persistCart();
    notifyListeners();
  }

  Future<void> buyNow(Book b) async {
    clearCart();
    addOne(b);
  }

  void setOrderStatus(String orderId, OrderStatus st) {
    _orderStatus[orderId] = st;
    _persistOrderMeta();
    notifyListeners();
  }

  void markPaid(String orderId) => setOrderStatus(orderId, OrderStatus.paid);
  void markShipping(String orderId) =>
      setOrderStatus(orderId, OrderStatus.shipping);
  void markDone(String orderId) => setOrderStatus(orderId, OrderStatus.done);

  /// Tiến 1 bước: pending|paid -> shipping -> done
  void advanceOrder(String orderId) {
    final cur = statusOf(orderId);
    switch (cur) {
      case OrderStatus.pending:
      case OrderStatus.paid:
        setOrderStatus(orderId, OrderStatus.shipping);
        break;
      case OrderStatus.shipping:
        setOrderStatus(orderId, OrderStatus.done);
        break;
      case OrderStatus.done:
        break;
    }
  }

  // ---------- Notifications ----------
  final List<AppNotification> _notis = [];
  List<AppNotification> get notifications => List.unmodifiable(_notis);
  int get unreadNoti => _notis.where((e) => !e.read).length;

  /// Thêm thông báo
  void addNotification(String title, String body) {
    _notis.insert(
      0,
      AppNotification(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        body: body,
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void markOneRead(String id) {
    final i = _notis.indexWhere((e) => e.id == id);
    if (i != -1 && !_notis[i].read) {
      _notis[i] = _notis[i].copyWith(read: true);
      notifyListeners();
    }
  }

  void markAllRead() {
    var changed = false;
    for (var i = 0; i < _notis.length; i++) {
      if (!_notis[i].read) {
        _notis[i] = _notis[i].copyWith(read: true);
        changed = true;
      }
    }
    if (changed) notifyListeners();
  }
}
