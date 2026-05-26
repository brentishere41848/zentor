import 'package:flutter/material.dart';
import '../../app/theme/pasus_colors.dart';

class PasusStatusPill extends StatelessWidget {
  const PasusStatusPill({
    required this.label,
    required this.color,
    this.icon,
    super.key,
  });

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.38)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 7),
          ],
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class PasusMark extends StatelessWidget {
  const PasusMark({this.size = 72, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.25),
        gradient: const LinearGradient(
          colors: [PasusColors.primaryAccent, PasusColors.secondaryAccent],
        ),
        boxShadow: [
          BoxShadow(
            color: PasusColors.primaryAccent.withValues(alpha: 0.22),
            blurRadius: 36,
          ),
        ],
      ),
      child: Icon(
        Icons.shield_outlined,
        color: PasusColors.background,
        size: size * 0.54,
      ),
    );
  }
}

class PasusPanel extends StatelessWidget {
  const PasusPanel({required this.child, this.padding, super.key});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: PasusColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: PasusColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.24),
            blurRadius: 30,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: child,
    );
  }
}
