import 'package:flutter/material.dart';

import '../../app/theme/zentor_colors.dart';

class ZentorErrorState extends StatelessWidget {
  const ZentorErrorState({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ZentorColors.danger.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ZentorColors.danger.withValues(alpha: 0.36)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: ZentorColors.danger),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: ZentorColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
