import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "../../application/state/app_state.dart";

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final isDark = app.themeMode == ThemeMode.dark;

    return Row(
      children: [
        const Text(
          "Sports Book Store",
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        const Spacer(),
        IconButton(
          tooltip: isDark ? "Chuyển Light Mode" : "Chuyển Dark Mode",
          onPressed: () => context.read<AppState>().toggleTheme(),
          icon: Icon(isDark ? Icons.wb_sunny_outlined : Icons.dark_mode_outlined),
        ),
      ],
    );
  }
}
