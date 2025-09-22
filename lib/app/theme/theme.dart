import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorSchemeSeed: const Color(0xFF4A6572),
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(centerTitle: true),
  );

  // Áp dụng Noto Sans cho toàn bộ text
  final noto = GoogleFonts.notoSansTextTheme(base.textTheme);

  return base.copyWith(
    textTheme: noto,
    // đảm bảo tiêu đề AppBar dùng đúng font/độ đậm
    appBarTheme: base.appBarTheme.copyWith(
      titleTextStyle: noto.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: Colors.black,
      ),
    ),
  );
}
