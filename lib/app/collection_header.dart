import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

class CollectionHeader extends StatelessWidget {
  const CollectionHeader({
    super.key,
    required this.title,
    required this.label,
    required this.artwork,
    required this.description,
    required this.actions,
    this.subtitle,
    this.background,
  });

  final String title;
  final String label;
  final String description;
  final String? subtitle;
  final Widget Function(double) artwork;
  final List<Widget> actions;
  final Widget? background;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: ColoredBox(
          color: colors.surfaceContainerHigh,
          child: Stack(
            children: [
              if (background case final image?)
                Positioned.fill(
                  child: ExcludeSemantics(
                    child: RepaintBoundary(
                      child: ImageFiltered(
                        imageFilter: ImageFilter.blur(
                          sigmaX: 18,
                          sigmaY: 18,
                          tileMode: TileMode.clamp,
                        ),
                        child: image,
                      ),
                    ),
                  ),
                ),
              Positioned.fill(
                child: ColoredBox(color: colors.surface.withValues(alpha: .84)),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth >= 600;
                    final size = wide ? 184.0 : 120.0;
                    final alignment = wide
                        ? CrossAxisAlignment.start
                        : CrossAxisAlignment.center;
                    final textAlign = wide ? TextAlign.start : TextAlign.center;
                    final cover = SizedBox.square(
                      dimension: size.clamp(0.0, constraints.maxWidth),
                      child: artwork(size),
                    );
                    final info = Column(
                      crossAxisAlignment: alignment,
                      children: [
                        Text(
                          title,
                          textAlign: textAlign,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (subtitle case final value?)
                          Text(
                            value,
                            textAlign: textAlign,
                            style: theme.textTheme.titleSmall,
                          ),
                        const SizedBox(height: 4),
                        Wrap(
                          alignment: wide
                              ? WrapAlignment.start
                              : WrapAlignment.center,
                          spacing: 8,
                          runSpacing: 2,
                          children: [
                            for (final value in [label, description])
                              Text(
                                value,
                                textAlign: textAlign,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          alignment: wide
                              ? WrapAlignment.start
                              : WrapAlignment.center,
                          spacing: 8,
                          runSpacing: 6,
                          children: actions,
                        ),
                      ],
                    );
                    return wide
                        ? Row(
                            children: [
                              cover,
                              const SizedBox(width: 24),
                              Expanded(child: info),
                            ],
                          )
                        : SizedBox(
                            width: double.infinity,
                            child: Column(
                              children: [
                                cover,
                                const SizedBox(height: 10),
                                info,
                              ],
                            ),
                          );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
