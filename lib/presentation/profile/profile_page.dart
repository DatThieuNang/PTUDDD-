import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sports_books/presentation/auth/auth_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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

          // (Bạn bổ sung các mục khác nếu cần)

          const SizedBox(height: 24),

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
        ],
      ),
    );
  }
}
