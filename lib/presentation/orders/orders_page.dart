import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "../../application/state/app_state.dart";
import "../../core/utils/money.dart";

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(title: const Text("Đơn hàng của tôi")),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemBuilder: (_, i) {
          final o = app.orders[i];
          return Card(
            child: ListTile(
              title: Text("Đơn #${o.id}  ${formatVnd(o.total)}"),
              subtitle: Text("${o.items.length} sản phẩm  ${o.createdAt}"),
              trailing: TextButton(
                onPressed: () => context.read<AppState>().reOrder(o),
                child: const Text("Mua lại"),
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemCount: app.orders.length,
      ),
    );
  }
}
