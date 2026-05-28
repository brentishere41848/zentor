import 'package:flutter/material.dart';

import '../../app/theme/zentor_colors.dart';

class ZentorButton extends StatelessWidget {
  const ZentorButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.secondary = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool secondary;

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 10)],
        Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
      ],
    );
    final style = ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
    if (secondary) {
      return OutlinedButton(
        onPressed: onPressed,
        style: style.copyWith(
          side: const WidgetStatePropertyAll(
            BorderSide(color: ZentorColors.border),
          ),
          foregroundColor: const WidgetStatePropertyAll(
            ZentorColors.textPrimary,
          ),
        ),
        child: child,
      );
    }
    return FilledButton(
      onPressed: onPressed,
      style: style.copyWith(
        backgroundColor: const WidgetStatePropertyAll(
          ZentorColors.primaryAccent,
        ),
        foregroundColor: const WidgetStatePropertyAll(ZentorColors.background),
      ),
      child: child,
    );
  }
}
