import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pasus_protocol/pasus_protocol.dart';

import '../../app/app_state.dart';
import '../../app/theme/pasus_colors.dart';
import 'pasus_bottom_nav.dart';
import 'pasus_sidebar.dart';
import 'pasus_status_card.dart';

class PasusShell extends ConsumerWidget {
  const PasusShell({required this.child, required this.location, super.key});

  final Widget child;
  final String location;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pasusControllerProvider);
    final isDesktop = MediaQuery.sizeOf(context).width >= 900;
    final content = Column(
      children: [
        Container(
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: PasusColors.border)),
          ),
          child: Row(
            children: [
              if (!isDesktop) ...[
                const PasusMark(size: 36),
                const SizedBox(width: 12),
                const Text(
                  'Pasus',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                ),
              ] else
                Text(
                  _titleFor(location),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              const Spacer(),
              Wrap(
                spacing: 10,
                children: [
                  PasusStatusPill(
                    label: state.cloudStatus.label,
                    color: _cloudColor(state.cloudStatus),
                    icon: Icons.cloud_outlined,
                  ),
                  PasusStatusPill(
                    label: state.protectionStatus.label,
                    color: _protectionColor(state.protectionStatus),
                    icon: Icons.shield_outlined,
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isDesktop ? 28 : 18),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1280),
                child: child,
              ),
            ),
          ),
        ),
      ],
    );

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.25,
            colors: [Color(0x1F26D9FF), PasusColors.background],
          ),
        ),
        child: isDesktop
            ? Row(
                children: [
                  PasusSidebar(location: location),
                  Expanded(child: content),
                ],
              )
            : content,
      ),
      bottomNavigationBar: isDesktop
          ? null
          : PasusBottomNav(location: location),
    );
  }

  String _titleFor(String location) {
    if (location.startsWith('/gaming')) return 'Gaming Protection';
    if (location.startsWith('/scan')) return 'Scan';
    if (location.startsWith('/quarantine')) return 'Quarantine';
    if (location.startsWith('/allowlist')) return 'Allowlist';
    if (location.startsWith('/protection')) return 'Protection';
    if (location.startsWith('/device')) return 'Device Integrity';
    if (location.startsWith('/logs')) return 'Security Events';
    if (location.startsWith('/settings')) return 'Settings';
    if (location.startsWith('/privacy')) return 'Privacy';
    return 'Protection Overview';
  }

  Color _cloudColor(CloudStatus status) => switch (status) {
    CloudStatus.online => PasusColors.success,
    CloudStatus.checking => PasusColors.primaryAccent,
    CloudStatus.disabled => PasusColors.textSecondary,
    CloudStatus.offline => PasusColors.warning,
    CloudStatus.misconfigured => PasusColors.danger,
  };

  Color _protectionColor(ProtectionStatus status) => switch (status) {
    ProtectionStatus.protected => PasusColors.success,
    ProtectionStatus.localOnly ||
    ProtectionStatus.partiallyProtected => PasusColors.warning,
    ProtectionStatus.starting ||
    ProtectionStatus.stopping => PasusColors.primaryAccent,
    ProtectionStatus.error => PasusColors.danger,
    ProtectionStatus.idle => PasusColors.textSecondary,
  };
}
