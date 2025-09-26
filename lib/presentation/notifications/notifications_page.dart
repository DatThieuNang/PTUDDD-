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
              child:
                  const Text('Đã đọc', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: items.isEmpty
          ? const Center(child: Text('Chưa có thông báo'))
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 8),
              itemBuilder: (_, i) {
                final n = items[i];
                return ListTile(
                  leading: Icon(
                    n.read
                        ? Icons.notifications_none
                        : Icons.notifications_active,
                  ),
                  title: Text(n.title),
                  subtitle: Text(
                    n.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(_fmtTime(n.createdAt),
                      style: const TextStyle(fontSize: 12)),
                  onTap: () => context.read<AppState>().markOneRead(n.id),
                );
              },
            ),
    );
  }

  String _fmtTime(DateTime t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
