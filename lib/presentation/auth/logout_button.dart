// lib/presentation/auth/logout_button.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_state.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AuthState>();
    return IconButton(
      tooltip: 'Đăng xuất',
      onPressed: s.status == AuthStatus.loading
          ? null
          : () => context.read<AuthState>().signOut(),
      icon: const Icon(Icons.logout),
    );
  }
}
