import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'application/state/app_state.dart';
import 'data/datasources/memory.dart';
import 'app/theme/theme.dart';
import 'presentation/home/home_page.dart';
import 'presentation/checkout/checkout_page.dart';

// Auth
import 'presentation/auth/auth_gate.dart';
import 'presentation/auth/auth_state.dart';

// Settings
import 'presentation/settings/settings_page.dart';

// Notifications
import 'presentation/notifications/notifications_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final ds = MemoryDataSource();
  final appState = AppState(ds);
  final authState = AuthState();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => appState..loadPersisted()),
        ChangeNotifierProvider(create: (_) => authState..bindAuthStream()),
      ],
      child: const SportsBooksApp(),
    ),
  );
}

class SportsBooksApp extends StatelessWidget {
  const SportsBooksApp({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();

    return MaterialApp(
      title: 'Sports Books',
      theme: buildAppTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: app.themeMode,
      debugShowCheckedModeBanner: false,
      routes: {
        '/checkout': (_) => const CheckoutPage(),
        '/settings': (_) => const SettingsPage(),
        '/notifications': (_) => const NotificationsPage(), // 👈 thêm
      },
      home: AuthGate(signedIn: const HomePage()),
    );
  }
}
