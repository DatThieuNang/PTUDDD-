import "dart:async";
import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "../../domain/entities/entities.dart";
import "../../application/state/app_state.dart";
import "../../core/utils/money.dart";
import "../orders/orders_page.dart";
import "payment_result_page.dart";

enum PaymentMethod { vnpay, momo, cod }

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

  PaymentMethod _method = PaymentMethod.cod;
  bool _processing = false;

  @override
  void dispose() {
    _name.dispose(); _phone.dispose(); _addr.dispose(); _city.dispose(); _coupon.dispose();
    super.dispose();
  }

  Future<void> _simulateGateway({
    required String gatewayName,
    required Future<void> Function() onSuccess,
  }) async {
    setState(() { _processing = true; });
    // mô phỏng chờ chuyển trang/nhập OTP, v.v.
    await Future.delayed(const Duration(seconds: 2));
    setState(() { _processing = false; });
    await onSuccess();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Thanh toán"),
        actions: [
          IconButton(
            tooltip: "Đơn hàng của tôi",
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrdersPage())),
            icon: const Icon(Icons.history),
          )
        ],
      ),
      body: AbsorbPointer(
        absorbing: _processing,
        child: Stack(
          children: [
            ListView(
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

                const Text("Phương thức thanh toán", style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Card(
                  child: Column(
                    children: [
                      RadioListTile<PaymentMethod>(
                        value: PaymentMethod.vnpay,
                        groupValue: _method,
                        onChanged: (v) => setState(() => _method = v!),
                        title: const Text("VNPay"),
                        subtitle: const Text("Thẻ nội địa/QR  mô phỏng cổng thanh toán"),
                        secondary: const Icon(Icons.qr_code_2),
                      ),
                      const Divider(height: 0),
                      RadioListTile<PaymentMethod>(
                        value: PaymentMethod.momo,
                        groupValue: _method,
                        onChanged: (v) => setState(() => _method = v!),
                        title: const Text("MoMo"),
                        subtitle: const Text("Ví điện tử  mô phỏng cổng thanh toán"),
                        secondary: const Icon(Icons.account_balance_wallet_outlined),
                      ),
                      const Divider(height: 0),
                      RadioListTile<PaymentMethod>(
                        value: PaymentMethod.cod,
                        groupValue: _method,
                        onChanged: (v) => setState(() => _method = v!),
                        title: const Text("COD (Thanh toán khi nhận hàng)"),
                        subtitle: const Text("Giao hàng rồi trả tiền"),
                        secondary: const Icon(Icons.delivery_dining_outlined),
                      ),
                    ],
                  ),
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
                        onPressed: app.cartSubtotal <= 0 || _processing ? null : () async {
                          // lưu địa chỉ
                          context.read<AppState>().address = Address(
                            fullName: _name.text, phone: _phone.text, line1: _addr.text, city: _city.text);

                          if (_method == PaymentMethod.cod) {
                            // Đặt hàng trực tiếp
                            final order = await context.read<AppState>().placeCurrentOrder();
                            if (!mounted) return;
                            if (order != null) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PaymentResultPage(
                                    success: true,
                                    method: "COD",
                                    orderId: order.id,
                                    amount: order.total,
                                  ),
                                ),
                              );
                            }
                            return;
                          }

                          // VNPay/MoMo: mô phỏng gateway
                          final gw = _method == PaymentMethod.vnpay ? "VNPay" : "MoMo";
                          await _simulateGateway(
                            gatewayName: gw,
                            onSuccess: () async {
                              final order = await context.read<AppState>().placeCurrentOrder();
                              if (!mounted) return;
                              if (order != null) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PaymentResultPage(
                                      success: true,
                                      method: gw,
                                      orderId: order.id,
                                      amount: order.total,
                                    ),
                                  ),
                                );
                              }
                            },
                          );
                        },
                        child: _processing
                            ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                            : Text("Thanh toán  ${formatVnd(app.cartTotal)}"),
                      ),
                    ),
                  ],
                )
              ],
            ),
            if (_processing)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.05),
                ),
              ),
          ],
        ),
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

