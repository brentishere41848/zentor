import 'package:flutter/material.dart';

import '../../app/theme/pasus_colors.dart';

class PasusErrorState extends StatelessWidget {
  const PasusErrorState({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PasusColors.danger.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PasusColors.danger.withValues(alpha: 0.36)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: PasusColors.danger),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: PasusColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
