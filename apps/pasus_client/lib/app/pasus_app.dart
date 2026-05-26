import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router.dart';
import 'theme/pasus_theme.dart';

class PasusApp extends ConsumerWidget {
  const PasusApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Pasus',
      debugShowCheckedModeBanner: false,
      theme: PasusTheme.dark(),
      routerConfig: router,
    );
  }
}
