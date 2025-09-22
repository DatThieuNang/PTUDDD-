import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "../../application/state/app_state.dart";
import "../../core/utils/money.dart";
import "../../domain/entities/entities.dart";

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});
  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _addr = TextEditingController();
  final _city = TextEditingController();
  final _coupon = TextEditingController();

  @override
  void dispose() {
    _name.dispose(); _phone.dispose(); _addr.dispose(); _city.dispose(); _coupon.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: const Text("Thanh toán")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text("Địa chỉ nhận hàng", style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          TextField(controller: _name, decoration: const InputDecoration(labelText: "Họ tên")),
          TextField(controller: _phone, decoration: const InputDecoration(labelText: "Số điện thoại"), keyboardType: TextInputType.phone),
          TextField(controller: _addr, decoration: const InputDecoration(labelText: "Địa chỉ")),
          TextField(controller: _city, decoration: const InputDecoration(labelText: "Tỉnh/Thành")),
          const SizedBox(height: 16),

          const Text("Mã giảm giá", style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _coupon,
                  decoration: const InputDecoration(hintText: "Nhập mã (FIT30, NEW10)..."),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  final msg = context.read<AppState>().applyCoupon(_coupon.text);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
                },
                child: const Text("Áp dụng"),
              )
            ],
          ),
          const SizedBox(height: 16),

          const Text("Tóm tắt đơn hàng", style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          _line("Tạm tính", formatVnd(app.cartSubtotal)),
          _line("Giảm", "- ${formatVnd(app.discount)}"),
          const Divider(height: 20),
          _line("Tổng thanh toán", formatVnd(app.cartTotal), bold: true),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Quay lại giỏ"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    // lưu địa chỉ
                    context.read<AppState>().address = Address(
                      fullName: _name.text, phone: _phone.text, line1: _addr.text, city: _city.text);
                    final order = await context.read<AppState>().placeCurrentOrder();
                    if (!mounted) return;
                    if (order != null) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đặt hàng thành công!")));
                      Navigator.pop(context); // về giỏ
                    }
                  },
                  child: const Text("Đặt hàng"),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _line(String label, String value, {bool bold = false}) {
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
