import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../application/state/app_state.dart';
import '../../domain/entities/entities.dart';
import '../../core/utils/money.dart';
import '../orders/orders_page.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();

  // Address
  final _nameCtl = TextEditingController();
  final _phoneCtl = TextEditingController();
  final _addrCtl = TextEditingController();
  final _cityCtl = TextEditingController();

  // Voucher
  final _couponCtl = TextEditingController();

  // Payment
  String _method = 'COD'; // COD | VNPay | MoMo

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final app = context.read<AppState>();
      final addr = app.address;
      if (addr != null) {
        _nameCtl.text = addr.fullName;
        _phoneCtl.text = addr.phone;
        _addrCtl.text = addr.line1;
        _cityCtl.text = addr.city;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _nameCtl.dispose();
    _phoneCtl.dispose();
    _addrCtl.dispose();
    _cityCtl.dispose();
    _couponCtl.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    final app = context.read<AppState>();

    if (app.cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Giỏ hàng trống')),
      );
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) return;

    app.address = Address(
      fullName: _nameCtl.text.trim(),
      phone: _phoneCtl.text.trim(),
      line1: _addrCtl.text.trim(),
      city: _cityCtl.text.trim(),
    );

    final order = await app.placeCurrentOrder(method: _method);
    if (!mounted) return;

    if (order == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể tạo đơn.')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Thanh toán thành công!')),
    );
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const OrdersPage()),
    );
  }

  void _applyCoupon() {
    final app = context.read<AppState>();
    final msg = app.applyCoupon(_couponCtl.text);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    setState(() {}); // refresh tổng tiền/discount
  }

  void _clearCoupon() {
    final app = context.read<AppState>();
    _couponCtl.clear();
    final msg = app.applyCoupon(''); // xóa mã
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Thanh toán')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          children: [
            // Địa chỉ giao hàng
            const Text('Địa chỉ giao hàng',
                style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameCtl,
              decoration: const InputDecoration(
                labelText: 'Họ và tên',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Nhập họ tên' : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _phoneCtl,
              decoration: const InputDecoration(
                labelText: 'Số điện thoại',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              validator: (v) =>
                  (v == null || v.trim().length < 8) ? 'SĐT chưa hợp lệ' : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _addrCtl,
              decoration: const InputDecoration(
                labelText: 'Địa chỉ (số nhà, đường)',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Nhập địa chỉ' : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _cityCtl,
              decoration: const InputDecoration(
                labelText: 'Tỉnh/Thành phố',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Nhập tỉnh/thành' : null,
            ),
            const SizedBox(height: 16),

            // Voucher / Mã giảm giá
            const Text('Mã giảm giá',
                style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _couponCtl,
                    decoration: const InputDecoration(
                      hintText: 'Nhập mã (ví dụ: FIT30, NEW10)',
                      border: OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.characters,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: app.cart.isEmpty ? null : _applyCoupon,
                  child: const Text('Áp dụng'),
                ),
              ],
            ),
            if (app.couponCode != null) ...[
              const SizedBox(height: 8),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                children: [
                  Chip(
                    label: Text('Mã: ${app.couponCode}'),
                    deleteIcon: const Icon(Icons.clear),
                    onDeleted: _clearCoupon,
                  ),
                  Text('Giảm: ${formatVnd(app.discount)}',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ],
            const SizedBox(height: 16),

            // Vận chuyển
            const Text('Vận chuyển',
                style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: app.shippingOptions
                      .firstWhere((e) => e['fee'] == app.shippingFee)['code']
                  as String,
              items: app.shippingOptions
                  .map((e) => DropdownMenuItem<String>(
                        value: e['code'] as String,
                        child: Text(
                            '${e['label']} • ${formatVnd(e['fee'] as int)}'),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) context.read<AppState>().setShipping(v);
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Phương thức thanh toán
            const Text('Phương thức thanh toán',
                style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            _methodTile('COD', 'Thanh toán khi nhận hàng'),
            _methodTile('VNPay', 'Cổng VNPay (mô phỏng)'),
            _methodTile('MoMo', 'Ví MoMo (mô phỏng)'),
            const SizedBox(height: 16),

            // Tóm tắt
            const Text('Tóm tắt đơn hàng',
                style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    _line('Tạm tính', formatVnd(app.cartSubtotal)),
                    _line('Giảm giá', '- ${formatVnd(app.discount)}'),
                    _line('Phí vận chuyển', formatVnd(app.shippingFee)),
                    const Divider(),
                    _line('Tổng thanh toán', formatVnd(app.grandTotal),
                        bold: true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: FilledButton(
          onPressed: _placeOrder,
          child: Text('Đặt hàng • ${formatVnd(app.grandTotal)}'),
        ),
      ),
    );
  }

  Widget _methodTile(String value, String subtitle) {
    return RadioListTile<String>(
      value: value,
      groupValue: _method,
      onChanged: (v) => setState(() => _method = v ?? 'COD'),
      title: Text(
        value == 'COD'
            ? 'Thanh toán khi nhận hàng (COD)'
            : (value == 'VNPay' ? 'VNPay' : 'MoMo'),
      ),
      subtitle: Text(subtitle),
      dense: true,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _line(String left, String right, {bool bold = false}) {
    final style = TextStyle(
      fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(left,
                style: style, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                right,
                style: style,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
