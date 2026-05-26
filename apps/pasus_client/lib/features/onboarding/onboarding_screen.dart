import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_state.dart';
import '../../app/theme/pasus_colors.dart';
import '../../shared/widgets/pasus_button.dart';
import '../../shared/widgets/pasus_status_card.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 880),
              child: PasusPanel(
                padding: const EdgeInsets.all(34),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const PasusMark(size: 72),
                    const SizedBox(height: 26),
                    Text(
                      'Pasus protects fair play.',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Pasus verifies your game session, game build, and protection status while keeping the user visibly in control.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: PasusColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 28),
                    const _OnboardingPoint(
                      icon: Icons.verified_user_outlined,
                      text:
                          'Pasus verifies your game session, game build, and protection status.',
                    ),
                    const _OnboardingPoint(
                      icon: Icons.folder_off_outlined,
                      text: 'Pasus does not scan unrelated personal files.',
                    ),
                    const _OnboardingPoint(
                      icon: Icons.visibility_outlined,
                      text: 'Pasus does not run hidden surveillance.',
                    ),
                    const _OnboardingPoint(
                      icon: Icons.touch_app_outlined,
                      text: 'You control when protection starts.',
                    ),
                    const SizedBox(height: 30),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        PasusButton(
                          label: 'Continue',
                          icon: Icons.arrow_forward,
                          onPressed: () async {
                            await ref
                                .read(pasusControllerProvider.notifier)
                                .completeOnboarding();
                            if (context.mounted) context.go('/home');
                          },
                        ),
                        PasusButton(
                          label: 'Privacy details',
                          icon: Icons.privacy_tip_outlined,
                          secondary: true,
                          onPressed: () => context.go('/privacy'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingPoint extends StatelessWidget {
  const _OnboardingPoint({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Icon(icon, color: PasusColors.primaryAccent),
          const SizedBox(width: 14),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
