import 'package:flutter/material.dart';

import '../../app/theme/zentor_colors.dart';
import '../../shared/widgets/zentor_status_card.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  static const points = [
    'Zentor scans common high-risk locations during Quick Scan.',
    'Zentor scans accessible local files during Full Scan and skips paths denied by the OS.',
    'Zentor scans only the file or folder you choose during Custom Scan.',
    'Zentor can automatically quarantine confirmed detections when scan mode allows it.',
    'Zentor never permanently deletes files automatically.',
    'Zentor does not steal credentials.',
    'Zentor does not read browser cookies.',
    'Zentor does not hide from the user.',
    'Zentor does not silently install kernel drivers. Windows driver protection is optional and user-visible.',
    'Zentor does not disable other security tools.',
    'Zentor logs local security events visibly.',
  ];

  @override
  Widget build(BuildContext context) {
    return ZentorPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Privacy-first by design',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          Text(
            'Zentor is a visible antivirus and security client. It is not a hidden system monitor and does not claim perfect detection.',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: ZentorColors.textSecondary),
          ),
          const SizedBox(height: 24),
          for (final point in points)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: ZentorColors.success,
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(point)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
