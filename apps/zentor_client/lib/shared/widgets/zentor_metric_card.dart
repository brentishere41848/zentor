import 'package:flutter/material.dart';

import '../../app/theme/zentor_colors.dart';
import 'zentor_status_card.dart';

class ZentorMetricCard extends StatelessWidget {
  const ZentorMetricCard({
    required this.title,
    required this.value,
    required this.icon,
    this.detail,
    super.key,
  });

  final String title;
  final String value;
  final String? detail;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ZentorPanel(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: ZentorColors.elevatedSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: ZentorColors.border),
            ),
            child: Icon(icon, color: ZentorColors.primaryAccent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: ZentorColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(value, style: Theme.of(context).textTheme.titleMedium),
                if (detail != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    detail!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: ZentorColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
