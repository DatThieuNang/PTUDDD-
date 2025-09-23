import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "../../application/state/app_state.dart";
import "../../core/utils/money.dart";
import "../checkout/checkout_page.dart";
import "../orders/orders_page.dart";

class TabCart extends StatelessWidget {
  const TabCart({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Giỏ hàng"),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrdersPage())),
          )
        ],
      ),
      body: app.cart.isEmpty
          ? const Center(child: Text("Giỏ hàng trống"))
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemBuilder: (_, i) {
                final it = app.cart[i];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.menu_book_outlined),
                    title: Text("${it.book.title}"),
                    subtitle: Text("${it.qty} x ${formatVnd(it.book.salePrice)}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () => app.decOne(it.book.id)),
                        IconButton(icon: const Icon(Icons.add_circle_outline),
                          onPressed: () => app.incOne(it.book.id)),
                        IconButton(icon: const Icon(Icons.delete_outline),
                          onPressed: () => app.removeItem(it.book.id)),
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemCount: app.cart.length,
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
        child: ElevatedButton(
          onPressed: () => Navigator.pushNamed(context, "/checkout"),
          child: Text("Thanh toán  ${formatVnd(app.cartSubtotal)}"),
        ),
      ),
    );
  }
}

