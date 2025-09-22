import '../repositories/repositories.dart';

class ClearCart {
  final CartRepository repo;
  ClearCart(this.repo);
  Future<void> call() => repo.setCart([]);
}
