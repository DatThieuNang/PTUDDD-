import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../application/state/app_state.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final items = app.notifications;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo'),
        actions: [
          if (app.unreadNoti > 0)
            TextButton(
              onPressed: () => context.read<AppState>().markAllRead(),
              child: const Text('Đánh dấu đã đọc'),
            ),
        ],
      ),
      body: items.isEmpty
          ? const Center(child: Text('Chưa có thông báo'))
          : ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final n = items[i];
                return ListTile(
                  leading: Icon(
                    n.read ? Icons.notifications : Icons.notifications_active,
                    color: n.read ? null : Colors.redAccent,
                  ),
                  title: Text(n.title,
                      style: TextStyle(
                        fontWeight: n.read ? FontWeight.w400 : FontWeight.w600,
                      )),
                  subtitle: Text(n.body),
                  trailing: Text(
                    timeLabel(n.createdAt),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  onTap: () => context.read<AppState>().markOneRead(n.id),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // demo: tự tạo 1 thông báo để test nhanh
          context.read<AppState>().addNotification(
                'Khuyến mãi mới',
                'Nhập mã FIT30 để giảm tới 50k!',
              );
        },
        icon: const Icon(Icons.add_alert),
        label: const Text('Tạo thông báo (demo)'),
      ),
    );
  }

  String timeLabel(DateTime dt) {
    final now = DateTime.now();
    final d = now.difference(dt);
    if (d.inMinutes < 1) return 'vừa xong';
    if (d.inMinutes < 60) return '${d.inMinutes} phút';
    if (d.inHours < 24) return '${d.inHours} giờ';
    return '${d.inDays} ngày';
  }
}
