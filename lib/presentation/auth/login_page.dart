import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final pass = TextEditingController();
  bool registering = false;

  @override
  void dispose() {
    email.dispose();
    pass.dispose();
    super.dispose();
  }

  Future<void> _submit(AuthState s) async {
    FocusScope.of(context).unfocus();
    final e = email.text.trim();
    final p = pass.text;

    if (e.isEmpty || p.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập email và mật khẩu')),
      );
      return;
    }

    if (registering) {
      await s.registerWithEmail(e, p);
    } else {
      await s.signInWithEmail(e, p);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AuthState>();

    return Scaffold(
      appBar: AppBar(title: Text(registering ? 'Đăng ký' : 'Đăng nhập')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: double.infinity,
              // đảm bảo nội dung đủ cao để không bị co cụm
              minHeight: MediaQuery.of(context).size.height -
                  kToolbarHeight -
                  MediaQuery.of(context).padding.top,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: pass,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Mật khẩu',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  onSubmitted: (_) => _submit(s),
                ),
                const SizedBox(height: 16),

                // Nút hành động chính đăng nhập/đăng ký
                FilledButton(
                  onPressed:
                      s.status == AuthStatus.loading ? null : () => _submit(s),
                  child: Text(registering ? 'Tạo tài khoản' : 'Đăng nhập'),
                ),
                const SizedBox(height: 8),
                // Đăng nhập Google
                OutlinedButton.icon(
                  onPressed: s.status == AuthStatus.loading
                      ? null
                      : () => s.signInWithGoogle(),
                  icon: const Icon(Icons.login),
                  label: const Text('Tiếp tục với Google'),
                ),

                if (s.status == AuthStatus.loading)
                  const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: LinearProgressIndicator(),
                  ),

                if (s.status == AuthStatus.error && s.error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      s.error!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),

                const SizedBox(height: 16),

                // Dòng chuyển đổi Đăng nhập <-> Đăng ký, dùng Wrap để tránh overflow
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      registering ? 'Đã có tài khoản?' : 'Chưa có tài khoản?',
                      softWrap: true,
                      textAlign: TextAlign.center,
                    ),
                    TextButton(
                      onPressed: s.status == AuthStatus.loading
                          ? null
                          : () => setState(() => registering = !registering),
                      child: Text(registering ? 'Đăng nhập' : 'Đăng ký ngay'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
