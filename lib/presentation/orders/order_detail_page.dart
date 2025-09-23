import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "../../application/state/app_state.dart";
import "../../domain/entities/entities.dart";
import "../../core/utils/money.dart";
import "../../data/datasources/memory.dart";

class OrderDetailPage extends StatelessWidget {
  final Order order;
  const OrderDetailPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final st = app.statusOf(order.id);
    final method = app.methodOf(order.id);
    final addr = app.address; // dùng địa chỉ hiện tại (demo)

    Color stColor = switch (st) {
      OrderStatus.pending  => Colors.orange,
      OrderStatus.paid     => Colors.blue,
      OrderStatus.shipping => Colors.purple,
      OrderStatus.done     => Colors.green,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text("Đơn #${order.id}"),
        actions: [
          PopupMenuButton<String>(
            onSelected: (k) {
              final ap = context.read<AppState>();
              switch (k) {
                case "paid": ap.markPaid(order.id); break;
                case "ship": ap.markShipping(order.id); break;
                case "done": ap.markDone(order.id); break;
                case "adv":  ap.advanceOrder(order.id); break;
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: "paid", child: Text("Đánh dấu ĐÃ THANH TOÁN")),
              PopupMenuItem(value: "ship", child: Text("Đánh dấu ĐANG GIAO")),
              PopupMenuItem(value: "done", child: Text("Hoàn tất đơn")),
              PopupMenuDivider(),
              PopupMenuItem(value: "adv", child: Text("Tiến 1 bước")),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // Trạng thái + thanh toán
          Row(
            children: [
              _badge("Trạng thái", st.name.toUpperCase(), stColor),
              const SizedBox(width: 8),
              _badge("Thanh toán", method, Colors.black54),
            ],
          ),
          const SizedBox(height: 12),

          // Địa chỉ giao (demo)
          Card(
            child: ListTile(
              leading: const Icon(Icons.location_on_outlined),
              title: Text(addr?.fullName ?? "Người nhận"),
              subtitle: Text(
                [
                  if (addr?.phone != null && addr!.phone.isNotEmpty) addr.phone,
                  if (addr?.line1 != null && addr!.line1.isNotEmpty) addr.line1,
                  if (addr?.city  != null && addr!.city.isNotEmpty)  addr.city,
                ].where((e) => e != null && e!.isNotEmpty).map((e) => e!).join("  "),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Danh sách sản phẩm
          const Text("Sản phẩm", style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          ...order.items.map((it) => Card(
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(width: 56, height: 56, child: MemoryDataSource.safeImage(it.book.image, fit: BoxFit.cover)),
              ),
              title: Text(it.book.title, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text("${it.qty}  ${formatVnd(it.book.salePrice)}"),
              trailing: Text(formatVnd(it.book.salePrice * it.qty), style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
          )),
          const SizedBox(height: 12),

          // Tổng kết
          const Text("Tổng kết", style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          _line("Tổng thanh toán", formatVnd(order.total), bold: true),

          const SizedBox(height: 16),
          if (st != OrderStatus.done)
            FilledButton.icon(
              onPressed: () => context.read<AppState>().advanceOrder(order.id),
              icon: const Icon(Icons.fast_forward),
              label: const Text("Tiến 1 bước trạng thái"),
            ),
        ],
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

  Widget _line(String label, String value, {bool bold=false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: TextStyle(fontWeight: bold ? FontWeight.w800 : FontWeight.w500)),
        ],
      ),
    );
  }
}
