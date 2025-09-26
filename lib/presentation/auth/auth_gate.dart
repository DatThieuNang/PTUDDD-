import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_state.dart';
import 'login_page.dart';

/// Dùng widget này làm `home:`
/// - Nếu đã đăng nhập -> hiển thị `signedIn`
/// - Nếu chưa -> hiển thị `LoginPage`
class AuthGate extends StatelessWidget {
  final Widget signedIn;
  const AuthGate({super.key, required this.signedIn});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AuthState>();

    // Đang xử lý auth -> overlay loading
    final loading = s.status == AuthStatus.loading;

    // Đã đăng nhập
    if (s.isSignedIn) {
      return Stack(
        children: [
          signedIn,
          if (loading)
            const ColoredBox(
              color: Color(0x88000000),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      );
    }

    // Chưa đăng nhập -> LoginPage
    return const LoginPage();
  }
}
