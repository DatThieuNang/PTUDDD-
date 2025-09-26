import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "application/state/app_state.dart";
import "data/datasources/memory.dart";
import "app/theme/theme.dart";
import "presentation/home/home_page.dart";
import "presentation/checkout/checkout_page.dart";

import "package:firebase_core/firebase_core.dart";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final ds = MemoryDataSource();
  final appState = AppState(ds);
  runApp(
    ChangeNotifierProvider(
      create: (_) => appState..loadPersisted(),
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
      title: "Sports Books",
      theme: buildAppTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: app.themeMode,
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
      routes: {
        "/checkout": (_) => const CheckoutPage(),
      },
    );
  }
}
