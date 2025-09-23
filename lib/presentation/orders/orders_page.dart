import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "../../application/state/app_state.dart";
import "../../core/utils/money.dart";
import "order_detail_page.dart";

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});
  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> with SingleTickerProviderStateMixin {
  final tabs = const ["Tất cả","Chờ xác nhận","Đã thanh toán","Đang giao","Hoàn tất"];

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final list = app.orders;

    List filtered(int idx) {
      if (idx == 0) return list;
      return list.where((o) {
        final st = app.statusOf(o.id);
        return switch (idx) {
          1 => st == OrderStatus.pending,
          2 => st == OrderStatus.paid,
          3 => st == OrderStatus.shipping,
          4 => st == OrderStatus.done,
          _ => true,
        };
      }).toList();
    }

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Đơn hàng của tôi"),
          bottom: TabBar(
            isScrollable: true,
            tabs: [for (final t in tabs) Tab(text: t)],
          ),
        ),
        body: TabBarView(
          children: List.generate(tabs.length, (i) {
            final data = filtered(i);
            if (data.isEmpty) return const Center(child: Text("Không có đơn phù hợp"));
            return ListView.separated(
              padding: const EdgeInsets.all(12),
              itemBuilder: (_, j) {
                final o = data[j];
                final st = app.statusOf(o.id);
                final method = app.methodOf(o.id);
                final Color stColor = switch (st) {
                  OrderStatus.pending  => Colors.orange,
                  OrderStatus.paid     => Colors.blue,
                  OrderStatus.shipping => Colors.purple,
                  OrderStatus.done     => Colors.green,
                };
                return Card(
                  child: ListTile(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_)=> OrderDetailPage(order: o))),
                    title: Text("Đơn #${o.id}  ${formatVnd(o.total)}"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${o.items.length} sản phẩm  ${o.createdAt}  $method"),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            _badge("Trạng thái", st.name.toUpperCase(), stColor),
                            const SizedBox(width: 8),
                            _badge("Thanh toán", method, Colors.black54),
                          ],
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemCount: data.length,
            );
          }),
        ),
      ),
    );
  }

  Widget _badge(String k, String v, Color c) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: c.withOpacity(0.12),
        border: Border.all(color: c.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Text("$k: ", style: const TextStyle(fontSize: 12, color: Colors.black54)),
          Text(v, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: c)),
        ],
      ),
    );
  }
}
