import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/zentor_colors.dart';
import 'zentor_status_card.dart';

class ZentorNavDestination {
  const ZentorNavDestination(this.path, this.label, this.icon);

  final String path;
  final String label;
  final IconData icon;

  String get openSemanticLabel => 'Open $label';

  String get currentSemanticLabel => 'Current page, $label';

  String get navigationTooltip => 'Open $label';
}

const zentorDestinations = [
  ZentorNavDestination('/home', 'Home', Icons.shield_outlined),
  ZentorNavDestination('/scan', 'Scan', Icons.radar_outlined),
  ZentorNavDestination(
    '/protection',
    'Protection',
    Icons.verified_user_outlined,
  ),
  ZentorNavDestination('/quarantine', 'Quarantine', Icons.inventory_2_outlined),
  ZentorNavDestination('/allowlist', 'Allowlist', Icons.fact_check_outlined),
  ZentorNavDestination('/logs', 'Security Events', Icons.receipt_long_outlined),
  ZentorNavDestination('/device', 'Device', Icons.devices_outlined),
  ZentorNavDestination('/updates', 'Updates', Icons.system_update_alt_outlined),
  ZentorNavDestination('/settings', 'Settings', Icons.settings_outlined),
];

class ZentorSidebar extends StatelessWidget {
  const ZentorSidebar({required this.location, super.key});

  final String location;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'Primary navigation',
      explicitChildNodes: true,
      child: Container(
        width: 280,
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        decoration: const BoxDecoration(
          color: Color(0xFF080D16),
          border: Border(right: BorderSide(color: ZentorColors.border)),
        ),
        child: ListView(
          children: [
            const Row(
              children: [
                ZentorMark(size: 42),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Avorax',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'Security client',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: ZentorColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            for (final destination in zentorDestinations)
              _SidebarItem(
                destination: destination,
                active: location.startsWith(destination.path),
              ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ZentorColors.elevatedSurface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: ZentorColors.border),
              ),
              child: const Text(
                'Visible protection only. Avorax scans local files, quarantines confirmed detections, and only uses driver protection when explicitly installed.',
                style: TextStyle(
                  color: ZentorColors.textSecondary,
                  height: 1.45,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({required this.destination, required this.active});

  final ZentorNavDestination destination;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active
        ? ZentorColors.primaryAccent
        : ZentorColors.textSecondary;
    return Semantics(
      container: true,
      button: true,
      selected: active,
      label: active
          ? destination.currentSemanticLabel
          : destination.openSemanticLabel,
      child: ExcludeSemantics(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => context.go(destination.path),
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: active
                    ? ZentorColors.primaryAccent.withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: active
                      ? ZentorColors.primaryAccent.withValues(alpha: 0.25)
                      : Colors.transparent,
                ),
              ),
              child: Row(
                children: [
                  Icon(destination.icon, color: color, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      destination.label,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
