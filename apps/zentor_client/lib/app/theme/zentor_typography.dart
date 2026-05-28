import 'package:flutter/material.dart';

abstract final class ZentorTypography {
  static const fontFamily = 'Inter';

  static TextTheme textTheme = const TextTheme(
    displaySmall: TextStyle(
      fontSize: 42,
      height: 1.05,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
    ),
    headlineMedium: TextStyle(
      fontSize: 28,
      height: 1.18,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
    ),
    titleLarge: TextStyle(
      fontSize: 20,
      height: 1.25,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      height: 1.3,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
    ),
    bodyLarge: TextStyle(fontSize: 16, height: 1.55, letterSpacing: 0),
    bodyMedium: TextStyle(fontSize: 14, height: 1.5, letterSpacing: 0),
    labelLarge: TextStyle(
      fontSize: 14,
      height: 1.2,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      height: 1.2,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
    ),
  );
}
