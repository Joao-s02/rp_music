import 'package:flutter/material.dart';

final optionMenuShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(24),
);

PopupMenuItem<T> optionMenuItem<T>(
  T value,
  String label,
  IconData icon, {
  bool enabled = true,
}) => PopupMenuItem(
  value: value,
  enabled: enabled,
  padding: const EdgeInsets.symmetric(horizontal: 8),
  child: OptionMenuRow(label, icon, enabled: enabled),
);

class OptionMenuRow extends StatelessWidget {
  const OptionMenuRow(
    this.label,
    this.icon, {
    super.key,
    this.selected = false,
    this.enabled = true,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final foreground = selected ? colors.onPrimaryContainer : colors.onSurface;
    return Opacity(
      opacity: enabled ? 1 : .45,
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: ShapeDecoration(
          color: selected ? colors.primaryContainer : colors.surfaceContainer,
          shape: const StadiumBorder(),
        ),
        child: Row(
          children: [
            Icon(icon, size: 19, color: selected ? foreground : colors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(label, style: TextStyle(color: foreground)),
            ),
            if (selected)
              Icon(Icons.check_rounded, size: 18, color: foreground),
          ],
        ),
      ),
    );
  }
}
