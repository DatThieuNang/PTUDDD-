import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../application/state/app_state.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Sports Book Store',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        const Spacer(),
        // Nút chuông thông báo + badge
        IconButton(
          tooltip: 'Thông báo',
          onPressed: () => Navigator.pushNamed(context, '/notifications'),
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.notifications_outlined),
              // Badge đếm số thông báo chưa đọc
              Selector<AppState, int>(
                selector: (_, s) => s.unreadNoti,
                builder: (_, count, __) {
                  if (count <= 0) return const SizedBox.shrink();
                  return Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$count',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
