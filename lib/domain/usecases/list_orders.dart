import '../entities/entities.dart';
import '../repositories/repositories.dart';

class ListOrders {
  final OrderRepository repo;
  ListOrders(this.repo);
  Future<List<Order>> call() => repo.getOrders();
}
