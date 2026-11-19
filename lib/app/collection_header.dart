import 'pulse_surface.dart';

import 'dart:math';

import 'package:flutter/material.dart';

class CollectionHeader extends StatelessWidget {
  const CollectionHeader({
    super.key,
    required this.title,
    required this.label,
    required this.artwork,
    required this.description,
    required this.actions,
    this.equalActions = false,
  });
  final String title, label, description;
  final Widget Function(double) artwork;
  final List<Widget> actions;
  final bool equalActions;
  @override
  Widget build(BuildContext context) => PulseSurface(
    inset: const EdgeInsets.all(12),
    child: Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.surfaceContainerHigh,
            Theme.of(context).colorScheme.surfaceContainer,
          ],
        ),
      ),
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, box) {
              final compact = MediaQuery.sizeOf(context).width < 420;
              final size = min(compact ? 150.0 : 280.0, box.maxWidth);
              return SizedBox(width: size, height: size, child: artwork(size));
            },
          ),
          const SizedBox(height: 20),
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.headlineMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(description, textAlign: TextAlign.center),
          const SizedBox(height: 18),
          if (equalActions &&
              MediaQuery.sizeOf(context).width >= 340 &&
              MediaQuery.textScalerOf(context).scale(14) <= 17)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < actions.length; i++) ...[
                    if (i > 0) const SizedBox(width: 8),
                    Expanded(child: actions[i]),
                  ],
                ],
              ),
            )
          else
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: actions,
            ),
        ],
      ),
    ),
  );
}
