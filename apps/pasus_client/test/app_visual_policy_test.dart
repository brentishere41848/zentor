import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pasus_client/app/theme/pasus_colors.dart';
import 'package:pasus_client/app/theme/pasus_theme.dart';

void main() {
  test('app background is the flat Pasus dark color', () {
    final theme = PasusTheme.dark();

    expect(theme.scaffoldBackgroundColor, PasusColors.background);
    expect(PasusColors.background, const Color(0xFF070B12));
  });
}
