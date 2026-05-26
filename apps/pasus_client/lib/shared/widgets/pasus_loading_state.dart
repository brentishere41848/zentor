import 'package:flutter/material.dart';

import '../../app/theme/pasus_colors.dart';

class PasusLoadingState extends StatelessWidget {
  const PasusLoadingState({this.message = 'Working...', super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        const SizedBox(width: 12),
        Text(message, style: const TextStyle(color: PasusColors.textSecondary)),
      ],
    );
  }
}
