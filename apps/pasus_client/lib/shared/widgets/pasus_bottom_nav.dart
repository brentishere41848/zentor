import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'pasus_sidebar.dart';

class PasusBottomNav extends StatelessWidget {
  const PasusBottomNav({required this.location, super.key});

  final String location;

  @override
  Widget build(BuildContext context) {
    final mobileDestinations = pasusDestinations
        .where(
          (destination) =>
              destination.path == '/home' ||
              destination.path == '/scan' ||
              destination.path == '/quarantine' ||
              destination.path == '/settings',
        )
        .toList();
    final selectedIndex = mobileDestinations.indexWhere(
      (destination) => location.startsWith(destination.path),
    );
    return NavigationBar(
      selectedIndex: selectedIndex < 0 ? 0 : selectedIndex,
      onDestinationSelected: (index) =>
          context.go(mobileDestinations[index].path),
      destinations: [
        for (final destination in mobileDestinations)
          NavigationDestination(
            icon: Icon(destination.icon),
            label: destination.label,
          ),
      ],
    );
  }
}
