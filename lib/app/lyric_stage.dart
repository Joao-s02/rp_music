import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../domain/lyrics.dart';

class LyricBackdrop extends StatelessWidget {
  const LyricBackdrop({super.key, required this.position, required this.child});
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
    return AnimatedScale(
      scale: active ? 1 : .96,
      alignment: Alignment.centerLeft,
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      child: line.words.isEmpty || !active
          ? Text(line.text.isEmpty ? '♪' : line.text, style: style)
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
            ),
    );
  }
}

class LyricScene extends StatelessWidget {
  const LyricScene({
    super.key,
    required this.lyrics,
    required this.position,
    required this.title,
    required this.artist,
  });
  final Lyrics lyrics;
  final Duration position;
  final String title, artist;
  @override
  Widget build(BuildContext context) {
    final index = lyrics.activeAt(position);
    final selected = index.clamp(0, lyrics.lines.length - 1);
    final line = lyrics.lines[selected];
    final reduce = MediaQuery.disableAnimationsOf(context);
    return LayoutBuilder(
      builder: (context, box) {
        final font = math.min(60.0, box.maxWidth < 500 ? 38.0 : 52.0);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              Text(
                artist,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall,
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (selected > 0)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 28),
                            child: Text(
                              lyrics.lines[selected - 1].text,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: font * .52,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.onSurface
                                    .withValues(alpha: .22),
                              ),
                            ),
                          ),
                        AnimatedSwitcher(
                          duration: reduce
                              ? Duration.zero
                              : const Duration(milliseconds: 460),
                          switchInCurve: Curves.easeOutCubic,
                          transitionBuilder: (child, animation) =>
                              FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, .12),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                ),
                              ),
                          child: Align(
                            key: ValueKey(selected),
                            alignment: Alignment.centerLeft,
                            child: LyricPhrase(
                              line: line,
                              position: position,
                              active: index >= 0,
                              size: font,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (selected + 1 < lyrics.lines.length)
                          Text(
                            lyrics.lines[selected + 1].text,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: font * .52,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.onSurface
                                  .withValues(alpha: .32),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: Text(
                  'RP MUSIC',
                  style: TextStyle(
                    letterSpacing: 5,
                    fontSize: 10,
                    color: Theme.of(context).colorScheme.onSurface
                        .withValues(alpha: .3),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
