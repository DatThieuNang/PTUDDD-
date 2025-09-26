import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sports_books/presentation/auth/auth_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AuthState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Hồ sơ')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Thông tin người dùng
          ListTile(
            leading: const Icon(Icons.person),
            title: Text(s.isSignedIn
                ? (s.user?.email ?? 'Đã đăng nhập')
                : 'Xin chào, Khách'),
            subtitle: Text(
              s.isSignedIn
                  ? 'Đăng nhập bằng ${s.user?.providerData.first.providerId}'
                  : 'Hồ sơ đang cập nhật',
            ),
          ),
          const Divider(height: 24),

          // Đơn hàng của tôi
          ListTile(
            leading: const Icon(Icons.receipt_long_outlined),
            title: const Text('Đơn hàng của tôi'),
            onTap: () {
              // TODO: Điều hướng đến trang đơn hàng nếu đã có
              // Navigator.pushNamed(context, '/orders');
            },
            trailing: const Icon(Icons.chevron_right),
          ),

          // Cài đặt -> đi tới SettingsPage
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Cài đặt'),
            onTap: () => Navigator.pushNamed(context, '/settings'),
            trailing: const Icon(Icons.chevron_right),
          ),

          const SizedBox(height: 24),

          // Trạng thái (loading / error)
          if (s.status == AuthStatus.loading)
            const Center(
                child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: CircularProgressIndicator(),
            )),
          if (s.status == AuthStatus.error && s.error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(s.error!, style: const TextStyle(color: Colors.red)),
            ),

          // Nút hành động
          if (s.isSignedIn)
            OutlinedButton.icon(
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
