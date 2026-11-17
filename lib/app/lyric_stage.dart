import 'dart:ui' as ui;
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../domain/lyrics.dart';

class LyricBackdrop extends StatelessWidget {
  const LyricBackdrop({
    super.key,
    required this.position,
    required this.child,
    this.cover,
  });
  final ImageProvider? cover;
  final Duration position;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final phase = MediaQuery.disableAnimationsOf(context)
        ? 0.0
        : position.inMilliseconds / 18000;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: dark ? const Color(0xff090b16) : const Color(0xfff6f3fd),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: AnimatedContainer(
              duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : const Duration(milliseconds: 700),
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(-.6 + math.sin(phase) * .3, -.5),
                  radius: 1.4,
                  colors: [
                    const Color(0xff7943cb).withValues(alpha: dark ? .24 : .09),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: AnimatedContainer(
              duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : const Duration(milliseconds: 700),
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(.8, .5 + math.cos(phase) * .25),
                  radius: 1,
                  colors: [
                    const Color(0xff47efe0).withValues(alpha: dark ? .12 : .08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          if (cover != null)
            Positioned.fill(
              child: ClipRect(
                child: ImageFiltered(
                  imageFilter: ui.ImageFilter.blur(
                    sigmaX: 26,
                    sigmaY: 26,
                    tileMode: ui.TileMode.clamp,
                  ),
                  child: Image(
                    image: cover!,
                    fit: BoxFit.cover,
                    color:
                        (dark
                                ? const Color(0xff090b16)
                                : const Color(0xfff6f3fd))
                            .withValues(alpha: .76),
                    colorBlendMode: BlendMode.srcATop,
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
          Material(type: MaterialType.transparency, child: child),
        ],
      ),
    );
  }
}

class LyricPhrase extends StatelessWidget {
  const LyricPhrase({
    super.key,
    required this.line,
    required this.position,
    required this.active,
    this.size = 34,
  });
  final LyricLine line;
  final Duration position;
  final bool active;
  final double size;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bright = dark ? Colors.white : colors.onSurface;
    final style = TextStyle(
      fontFamily: 'Plus Jakarta Sans',
      fontSize: size,
      height: 1.25,
      fontWeight: FontWeight.w800,
      letterSpacing: -.8,
      color: active ? bright : colors.onSurface.withValues(alpha: .38),
      shadows: active && dark
          ? [
              Shadow(
                color: colors.primary.withValues(alpha: .2),
                blurRadius: 28,
              ),
            ]
          : null,
    );
    final alignment = line.rightAligned
        ? Alignment.centerRight
        : Alignment.centerLeft;
    final textAlign = line.rightAligned ? TextAlign.right : TextAlign.left;
    return AnimatedScale(
      scale: active ? 1 : .96,
      alignment: alignment,
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      child: line.words.isEmpty || !active
          ? Text(
              line.text.isEmpty ? '♪' : line.text,
              style: style,
              textAlign: textAlign,
            )
          : Text.rich(
              TextSpan(
                children: [
                  if (line.leadingText.isNotEmpty)
                    TextSpan(text: line.leadingText, style: style),
                  ...line.words.map(
                    (word) => TextSpan(
                      text: word.text,
                      style: style.copyWith(
                        color: position >= word.time
                            ? bright
                            : colors.onSurface.withValues(alpha: .3),
                      ),
                    ),
                  ),
                ],
              ),
              textAlign: textAlign,
            ),
    );
  }
}

/// Song identity shared by both lyrics modes.
class LyricSongHeader extends StatelessWidget {
  const LyricSongHeader({
    super.key,
    required this.title,
    required this.artist,
    this.cover,
  });
  final String title, artist;
  final ImageProvider? cover;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: SizedBox.square(
          dimension: 48,
          child: cover == null
              ? ColoredBox(
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  child: const Icon(Icons.music_note),
                )
              : Image(
                  image: cover!,
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                  errorBuilder: (_, _, _) => const Icon(Icons.music_note),
                ),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            Text(
              artist,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    ],
  );
}
