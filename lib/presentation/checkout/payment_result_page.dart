import "package:flutter/material.dart";
import "../../core/utils/money.dart";

class PaymentResultPage extends StatelessWidget {
  final bool success;
  final String method;
  final String orderId;
  final int amount;

  const PaymentResultPage({
    super.key,
    required this.success,
    required this.method,
    required this.orderId,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    final icon = success ? Icons.check_circle : Icons.cancel;
    final color = success ? Colors.green : Colors.red;

    return Scaffold(
      appBar: AppBar(title: const Text("Kết quả thanh toán")),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 56),
                const SizedBox(height: 12),
                Text(
                  success ? "Thanh toán thành công" : "Thanh toán thất bại",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color),
                ),
                const SizedBox(height: 12),
                _row("Mã đơn", "#$orderId"),
                _row("Phương thức", method),
                _row("Số tiền", formatVnd(amount)),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
                  child: const Text("Về trang chính"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(String k, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Expanded(child: Text(k, style: const TextStyle(color: Colors.black54))),
        Text(v, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    ),
  );
}
