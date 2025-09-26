import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sports_books/presentation/auth/auth_state.dart';
import '../orders/orders_page.dart';

class TabProfile extends StatelessWidget {
  const TabProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AuthState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ'),
        actions: [
          if (s.isSignedIn)
            IconButton(
              tooltip: 'Đăng xuất',
              icon: const Icon(Icons.logout),
              onPressed: () => context.read<AuthState>().signOut(),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: Text(
              s.isSignedIn
                  ? (s.user?.email ?? 'Đã đăng nhập')
                  : 'Xin chào, Khách',
            ),
            subtitle: Text(
              s.isSignedIn
                  ? 'Đăng nhập bằng ${s.user?.providerData.first.providerId}'
                  : 'Hồ sơ đang cập nhật',
            ),
          ),
          const Divider(height: 32),

          // Đơn hàng
          ListTile(
            leading: const Icon(Icons.receipt_long_outlined),
            title: const Text('Đơn hàng của tôi'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OrdersPage()),
              );
            },
          ),

          // Cài đặt -> mở trang Settings
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Cài đặt'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, '/settings'),
          ),

          const SizedBox(height: 24),

          // Trạng thái
          if (s.status == AuthStatus.loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Center(child: CircularProgressIndicator()),
            ),
          if (s.status == AuthStatus.error && s.error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(s.error!, style: const TextStyle(color: Colors.red)),
            ),

          // Hành động
          if (s.isSignedIn)
            ElevatedButton.icon(
              onPressed: () => context.read<AuthState>().signOut(),
              icon: const Icon(Icons.logout),
              label: const Text('Đăng xuất'),
            )
          else ...[
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pushNamed('/login'),
              icon: const Icon(Icons.login),
              label: const Text('Đăng nhập'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => context.read<AuthState>().signInWithGoogle(),
              icon: const Icon(Icons.g_mobiledata),
              label: const Text('Đăng nhập Google'),
            ),
          ],

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
