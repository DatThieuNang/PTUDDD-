import 'package:flutter/material.dart';
import '../orders/orders_page.dart';

class TabProfile extends StatelessWidget {
  const TabProfile({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hồ sơ')),
      body: ListView(
        children: [
          const ListTile(
            leading: Icon(Icons.person),
            title: Text('Xin chào, Khách'),
            subtitle: Text('Hồ sơ đang cập nhật'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.receipt_long_outlined),
            title: const Text('Đơn hàng của tôi'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrdersPage())),
          ),
          const Divider(height: 1),
          const ListTile(
            leading: Icon(Icons.settings_outlined),
            title: Text('Cài đặt (đang cập nhật)'),
          ),
        ],
      ),
    );
  }
}
