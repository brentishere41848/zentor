import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zentor_client/app/theme/zentor_colors.dart';
import 'package:zentor_client/app/theme/zentor_theme.dart';

void main() {
  test('app background is the flat Zentor dark color', () {
    final theme = ZentorTheme.dark();

    expect(theme.scaffoldBackgroundColor, ZentorColors.background);
    expect(ZentorColors.background, const Color(0xFF070B12));
  });
}
