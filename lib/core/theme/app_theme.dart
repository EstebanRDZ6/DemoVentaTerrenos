import 'package:flutter/material.dart';

class AppTheme {
  static const Color brand = Color(0xFF0A4D68);
  static const Color accent = Color(0xFFE7A93B);
  static const Color lightSurface = Color(0xFFF5F7F9);
  static const Color darkSurface = Color(0xFF0D151B);

  static ThemeData get lightTheme {
    final scheme = ColorScheme.fromSeed(seedColor: brand, brightness: Brightness.light).copyWith(primary: brand, secondary: accent, onPrimary: Colors.white);
    return _base(scheme, Brightness.light, Colors.white, lightSurface);
  }

  static ThemeData get darkTheme {
    final scheme = ColorScheme.fromSeed(seedColor: brand, brightness: Brightness.dark).copyWith(primary: const Color(0xFF69C7E7), secondary: const Color(0xFFFFC857), surface: const Color(0xFF121D24));
    return _base(scheme, Brightness.dark, const Color(0xFF16232C), darkSurface);
  }

  static ThemeData _base(ColorScheme scheme, Brightness brightness, Color cardColor, Color scaffoldColor) => ThemeData(
        useMaterial3: true,
        brightness: brightness,
        colorScheme: scheme,
        scaffoldBackgroundColor: scaffoldColor,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: AppBarTheme(backgroundColor: cardColor, foregroundColor: scheme.onSurface, elevation: 0, scrolledUnderElevation: 0),
        cardTheme: CardThemeData(elevation: 0, color: cardColor, margin: EdgeInsets.zero, surfaceTintColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22))),
        dividerTheme: DividerThemeData(color: brightness == Brightness.light ? const Color(0xFFE2E8EC) : const Color(0xFF263640)),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: brightness == Brightness.light ? Colors.white : const Color(0xFF17242C),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: scheme.outlineVariant)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: scheme.outlineVariant)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: scheme.primary, width: 1.6)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(backgroundColor: scheme.primary, foregroundColor: scheme.onPrimary, elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)))),
        filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(backgroundColor: scheme.primary, foregroundColor: scheme.onPrimary, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)))),
        outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(foregroundColor: scheme.primary, side: BorderSide(color: scheme.outlineVariant), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)))),
        chipTheme: ChipThemeData(backgroundColor: brightness == Brightness.light ? const Color(0xFFEDF3F5) : const Color(0xFF1D303A), selectedColor: brightness == Brightness.light ? const Color(0xFFD9EDF3) : const Color(0xFF254D5C), side: BorderSide.none, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4)),
        textTheme: TextTheme(
          displaySmall: const TextStyle(fontSize: 40, fontWeight: FontWeight.w800, letterSpacing: -1.3),
          headlineMedium: const TextStyle(fontSize: 29, fontWeight: FontWeight.w800, letterSpacing: -.6),
          headlineSmall: const TextStyle(fontSize: 24, fontWeight: FontWeight.w750),
          titleLarge: const TextStyle(fontSize: 20, fontWeight: FontWeight.w750),
          titleMedium: const TextStyle(fontSize: 16, fontWeight: FontWeight.w650),
          bodyLarge: TextStyle(fontSize: 16, height: 1.5, color: scheme.onSurface),
          bodyMedium: TextStyle(fontSize: 14, height: 1.45, color: scheme.onSurfaceVariant),
        ),
      );
}
