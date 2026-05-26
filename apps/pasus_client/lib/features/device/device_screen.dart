import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_state.dart';
import '../../shared/widgets/pasus_loading_state.dart';
import '../../shared/widgets/pasus_metric_card.dart';

class DeviceScreen extends ConsumerWidget {
  const DeviceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(deviceSummaryProvider);
    return summary.when(
      loading: () =>
          const PasusLoadingState(message: 'Reading platform info...'),
      error: (error, _) => PasusMetricCard(
        title: 'Device',
        value: 'Unable to read platform info',
        detail: '$error',
        icon: Icons.error_outline,
      ),
      data: (value) => LayoutBuilder(
        builder: (context, constraints) {
          final cards = [
            PasusMetricCard(
              title: 'Platform',
              value: value.platform,
              detail: value.osVersion,
              icon: Icons.devices_outlined,
            ),
            PasusMetricCard(
              title: 'App version',
              value: value.appVersion,
              icon: Icons.info_outline,
            ),
            PasusMetricCard(
              title: 'Device identifier hash status',
              value: value.deviceIdentifierHashStatus,
              detail: 'Raw identifiers are not displayed or stored.',
              icon: Icons.fingerprint,
            ),
            PasusMetricCard(
              title: 'Local core status',
              value: value.localCoreStatus,
              icon: Icons.memory_outlined,
            ),
            PasusMetricCard(
              title: 'Permissions status',
              value: value.permissionsStatus,
              icon: Icons.lock_outline,
            ),
          ];
          if (constraints.maxWidth < 900) {
            return Column(
              children: [
                for (final card in cards) ...[card, const SizedBox(height: 12)],
              ],
            );
          }
          return GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 2.6,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: cards,
          );
        },
      ),
    );
  }
}
