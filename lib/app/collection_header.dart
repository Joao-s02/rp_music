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
  });
  final String title, label, description;
  final Widget Function(double) artwork;
  final List<Widget> actions;
  @override
  Widget build(BuildContext context) => PulseSurface(
    inset: const EdgeInsets.all(20),
    child: Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
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
              final size = min(280.0, box.maxWidth);
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
            style: Theme.of(context).textTheme.headlineMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(description, textAlign: TextAlign.center),
          const SizedBox(height: 18),
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
