import 'package:flutter/material.dart';

import 'zentor_colors.dart';
import 'zentor_typography.dart';

abstract final class ZentorTheme {
  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: ZentorColors.primaryAccent,
      brightness: Brightness.dark,
      primary: ZentorColors.primaryAccent,
      secondary: ZentorColors.secondaryAccent,
      surface: ZentorColors.surface,
      error: ZentorColors.danger,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: ZentorColors.background,
      textTheme: ZentorTypography.textTheme.apply(
        bodyColor: ZentorColors.textPrimary,
        displayColor: ZentorColors.textPrimary,
      ),
      cardTheme: CardThemeData(
        color: ZentorColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: ZentorColors.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ZentorColors.elevatedSurface,
        labelStyle: const TextStyle(color: ZentorColors.textSecondary),
        hintStyle: const TextStyle(color: ZentorColors.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: ZentorColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: ZentorColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: ZentorColors.primaryAccent),
        ),
      ),
    );
  }
}
