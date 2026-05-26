import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_state.dart';
import '../../app/theme/pasus_colors.dart';
import '../../shared/widgets/pasus_button.dart';
import '../../shared/widgets/pasus_empty_state.dart';
import '../../shared/widgets/pasus_status_card.dart';

class LogsScreen extends ConsumerWidget {
  const LogsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pasusControllerProvider);
    final controller = ref.read(pasusControllerProvider.notifier);
    return PasusPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Local events',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              PasusButton(
                label: 'Export logs',
                icon: Icons.download_outlined,
                secondary: true,
                onPressed: () async {
                  final path = await controller.exportLogs();
                  if (context.mounted && path != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Logs exported to $path')),
                    );
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (state.events.isEmpty)
            const PasusEmptyState(
              title: 'No local events',
              message: 'Pasus records only real local app actions here.',
              icon: Icons.receipt_long_outlined,
            )
          else
            for (final event in state.events)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: PasusColors.elevatedSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: PasusColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.circle,
                      size: 10,
                      color: PasusColors.primaryAccent,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.message,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${event.type} • ${event.createdAt.toLocal()}${event.details == null ? '' : ' • ${event.details}'}',
                            style: const TextStyle(
                              color: PasusColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}
