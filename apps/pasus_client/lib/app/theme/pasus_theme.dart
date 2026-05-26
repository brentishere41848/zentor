import 'package:flutter/material.dart';

import 'pasus_colors.dart';
import 'pasus_typography.dart';

abstract final class PasusTheme {
  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: PasusColors.primaryAccent,
      brightness: Brightness.dark,
      primary: PasusColors.primaryAccent,
      secondary: PasusColors.secondaryAccent,
      surface: PasusColors.surface,
      error: PasusColors.danger,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: PasusColors.background,
      textTheme: PasusTypography.textTheme.apply(
        bodyColor: PasusColors.textPrimary,
        displayColor: PasusColors.textPrimary,
      ),
      cardTheme: CardThemeData(
        color: PasusColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: PasusColors.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: PasusColors.elevatedSurface,
        labelStyle: const TextStyle(color: PasusColors.textSecondary),
        hintStyle: const TextStyle(color: PasusColors.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: PasusColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: PasusColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: PasusColors.primaryAccent),
        ),
      ),
    );
  }
}
