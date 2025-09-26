import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../application/state/app_state.dart';
import '../auth/auth_state.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final auth = context.watch<AuthState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      body: ListView(
        children: [
          // Giao diện
          SwitchListTile.adaptive(
            value: app.themeMode == ThemeMode.dark,
            onChanged: (_) => context.read<AppState>().toggleThemeAndPersist(),
            secondary: const Icon(Icons.dark_mode_outlined),
            title: const Text('Chế độ tối'),
            subtitle: const Text('Đổi giao diện sáng/tối'),
          ),
          const Divider(height: 1),

          // Ngôn ngữ (demo)
          ListTile(
            leading: const Icon(Icons.language_outlined),
            title: const Text('Ngôn ngữ'),
            subtitle: const Text('Tiếng Việt'),
            onTap: () {
              showModalBottomSheet(
                context: context,
                builder: (_) => SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      ListTile(
                          leading: Icon(Icons.check),
                          title: Text('Tiếng Việt')),
                      ListTile(
                          leading: Icon(Icons.translate),
                          title: Text('English (sắp có)')),
                    ],
                  ),
                ),
              );
            },
          ),
          const Divider(height: 1),

          // Dọn dữ liệu tạm (giỏ hàng / yêu thích)
          ListTile(
            leading: const Icon(Icons.cleaning_services_outlined),
            title: const Text('Dọn dữ liệu tạm'),
            subtitle: const Text('Xoá giỏ hàng và danh sách yêu thích'),
            onTap: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Xác nhận'),
                  content: const Text(
                      'Bạn có chắc muốn xoá giỏ hàng và mục yêu thích?'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Huỷ')),
                    ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Xoá')),
                  ],
                ),
              );
              if (ok == true) {
                final a = context.read<AppState>();
                a.clearCart();
                // xoá từng wishlist id
                for (final id in a.wishlistIds.toList()) {
                  a.toggleWishlist(id);
                }
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã dọn dữ liệu tạm.')),
                  );
                }
              }
            },
          ),
          const Divider(height: 1),

          // Tài khoản
          if (auth.isSignedIn) ...[
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Tài khoản'),
              subtitle: Text(auth.user?.email ?? ''),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {}, // chỗ này sau có thể mở màn cập nhật hồ sơ
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Đăng xuất'),
              onTap: () => context.read<AuthState>().signOut(),
            ),
          ] else ...[
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Đăng nhập'),
              onTap: () => Navigator.of(context).pushNamed('/login'),
            ),
          ],
        ],
      ),
    );
  }
}
