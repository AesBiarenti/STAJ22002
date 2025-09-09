import 'package:flutter/material.dart';

class AppTheme {
  // Ana renkler - Sade ve Modern
  static const Color primaryGradientStart = Color(0xFF1E293B); // Slate 800
  static const Color primaryGradientEnd = Color(0xFF334155); // Slate 700
  static const Color secondaryGradientStart = Color(0xFF0F172A); // Slate 900
  static const Color secondaryGradientEnd = Color(0xFF1E293B); // Slate 800

  // Arka plan gradient'ları
  static const LinearGradient backgroundGradientLight = LinearGradient(
    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient backgroundGradientDark = LinearGradient(
    colors: [Color(0xFF020617), Color(0xFF0F172A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient surfaceGradientLight = LinearGradient(
    colors: [Color(0xFF1E293B), Color(0xFF334155)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient surfaceGradientDark = LinearGradient(
    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Nötr renkler - Daha yumuşak
  static const Color backgroundLight = Color(0xFF0F172A); // Slate 900
  static const Color surfaceLight = Color(0xFF1E293B); // Slate 800
  static const Color textPrimaryLight = Color(0xFFF8FAFC); // Slate 50
  static const Color textSecondaryLight = Color(0xFFCBD5E1); // Slate 300
  static const Color borderLight = Color(0xFF334155); // Slate 700

  // Karanlık tema renkleri
  static const Color backgroundDark = Color(0xFF020617); // Slate 950
  static const Color surfaceDark = Color(0xFF0F172A); // Slate 900
  static const Color textPrimaryDark = Color(0xFFF8FAFC); // Slate 50
  static const Color textSecondaryDark = Color(0xFFCBD5E1); // Slate 300
  static const Color borderDark = Color(0xFF1E293B); // Slate 800

  // Özel renkler - Daha sade ve tutarlı
  static const Color accentBlue = Color(0xFF3B82F6); // Blue 500
  static const Color accentGreen = Color(0xFF10B981); // Emerald 500
  static const Color accentCyan = Color(0xFF06B6D4); // Cyan 500
  static const Color accentTeal = Color(0xFF14B8A6); // Teal 500
  static const Color accentIndigo = Color(0xFF6366F1); // Indigo 500

  // Ek renkler - UI için gerekli
  static const Color accentRed = Color(0xFFEF4444); // Red 500
  static const Color accentPurple = Color(0xFF8B5CF6); // Purple 500
  static const Color accentOrange = Color(0xFFF59E0B); // Amber 500

  // Gradient'lar
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryGradientStart, primaryGradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondaryGradientStart, secondaryGradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Yeni gradient'lar - Sade ve Modern
  static const LinearGradient blueGradient = LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient greenGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cyanGradient = LinearGradient(
    colors: [Color(0xFF06B6D4), Color(0xFF0891B2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Özel border radius değerleri
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusExtraLarge = 24.0;

  // Özel shadow'lar
  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get mediumShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.1),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> get strongShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.15),
      blurRadius: 30,
      offset: const Offset(0, 12),
    ),
  ];

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true, // Material 3'ü kapatıyoruz
    brightness: Brightness.light,
    scaffoldBackgroundColor: backgroundLight,

    // Özel color scheme
    colorScheme: const ColorScheme.light(
      primary: primaryGradientStart,
      secondary: secondaryGradientStart,
      surface: surfaceLight,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textPrimaryLight,
      outline: borderLight,
    ),

    // Özel app bar teması
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: textPrimaryLight,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimaryLight,
      ),
    ),

    // Özel card teması
    cardTheme: CardThemeData(
      color: surfaceLight,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
        side: const BorderSide(color: borderLight, width: 1),
      ),
      shadowColor: Colors.transparent,
    ),

    // Özel text teması
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textPrimaryLight,
        letterSpacing: -0.5,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: textPrimaryLight,
        letterSpacing: -0.5,
      ),
      headlineLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textPrimaryLight,
        letterSpacing: -0.3,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimaryLight,
        letterSpacing: -0.3,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimaryLight,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: textPrimaryLight,
      ),
      bodyLarge: TextStyle(fontSize: 16, color: textPrimaryLight, height: 1.5),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: textSecondaryLight,
        height: 1.5,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textPrimaryLight,
      ),
    ),

    // Özel input decoration teması
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
        borderSide: const BorderSide(color: borderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
        borderSide: const BorderSide(color: borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
        borderSide: const BorderSide(color: primaryGradientStart, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),

    // Özel divider teması
    dividerTheme: const DividerThemeData(
      color: borderLight,
      thickness: 1,
      space: 1,
    ),

    // Özel floating action button teması
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryGradientStart,
      foregroundColor: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(borderRadiusLarge)),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: backgroundDark,

    colorScheme: const ColorScheme.dark(
      primary: primaryGradientStart,
      secondary: secondaryGradientStart,
      surface: surfaceDark,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textPrimaryDark,
      outline: borderDark,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: textPrimaryDark,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimaryDark,
      ),
    ),

    cardTheme: CardThemeData(
      color: surfaceDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
        side: const BorderSide(color: borderDark, width: 1),
      ),
      shadowColor: Colors.transparent,
    ),

    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textPrimaryDark,
        letterSpacing: -0.5,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: textPrimaryDark,
        letterSpacing: -0.5,
      ),
      headlineLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textPrimaryDark,
        letterSpacing: -0.3,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimaryDark,
        letterSpacing: -0.3,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimaryDark,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: textPrimaryDark,
      ),
      bodyLarge: TextStyle(fontSize: 16, color: textPrimaryDark, height: 1.5),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: textSecondaryDark,
        height: 1.5,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textPrimaryDark,
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
        borderSide: const BorderSide(color: borderDark),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
        borderSide: const BorderSide(color: borderDark),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
        borderSide: const BorderSide(color: primaryGradientStart, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),

    dividerTheme: const DividerThemeData(
      color: borderDark,
      thickness: 1,
      space: 1,
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryGradientStart,
      foregroundColor: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(borderRadiusLarge)),
      ),
    ),
  );
}
