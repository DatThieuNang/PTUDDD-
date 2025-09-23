import "package:flutter/material.dart";

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    colorSchemeSeed: const Color(0xFF1976D2),
    brightness: Brightness.light,
  );
}

ThemeData buildDarkTheme() {
  return ThemeData(
    useMaterial3: true,
    colorSchemeSeed: const Color(0xFF1976D2),
    brightness: Brightness.dark,
  );
}
