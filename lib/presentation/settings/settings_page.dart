import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../application/state/app_state.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      body: ListView(
        children: [
          const _SectionTitle('Giao diện'),
          SwitchListTile(
            title: const Text('Chế độ tối'),
            subtitle: const Text('Bật/tắt Dark Mode'),
            value: app.themeMode == ThemeMode.dark,
            onChanged: (_) => context.read<AppState>().toggleThemeAndPersist(),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Ngôn ngữ'),
            subtitle: const Text('Tiếng Việt (đang cập nhật)'),
            onTap: () {},
          ),
          const Divider(),
          const _SectionTitle('Thông báo'),
          SwitchListTile(
            title: const Text('Thông báo khuyến mãi'),
            value: true,
            onChanged: (_) {}, // placeholder
          ),
          SwitchListTile(
            title: const Text('Thông báo đơn hàng'),
            value: true,
            onChanged: (_) {}, // placeholder
          ),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('Xem thông báo'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).pushNamed('/notifications'),
          ),
          const Divider(),
          const _SectionTitle('Khác'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Giới thiệu & phiên bản'),
            subtitle: const Text('Sports Books 1.0.0'),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text, {super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}
