import 'package:flutter/material.dart';

/// A record sleeve opening into five cyan/violet grooves, the collection motif
/// of RP Music. The cover remains readable and reduced motion stays static.
class AlbumSleeve extends StatelessWidget {
  const AlbumSleeve({super.key, required this.child, this.playing = false});
  final Widget child;
  final bool playing;
  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final reduced = MediaQuery.disableAnimationsOf(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: reduced ? 1 : 0, end: 1),
      duration: reduced ? Duration.zero : const Duration(milliseconds: 1050),
      curve: Curves.easeOutCubic,
      builder: (context, opened, _) => Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            left: 25 + opened * 12,
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    colors: [
                      c.primary.withValues(alpha: .5),
                      c.surfaceContainerHighest,
                      c.secondary.withValues(alpha: .7),
                      c.surfaceContainerHighest,
                      c.primary.withValues(alpha: .5),
                    ],
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    for (var i = 0; i < 5; i++)
                      FractionallySizedBox(
                        widthFactor: .92 - i * .13,
                        heightFactor: .92 - i * .13,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: c.onSurface.withValues(alpha: .12),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedSlide(
            offset: Offset(playing && !reduced ? -.035 : 0, 0),
            duration: reduced
                ? Duration.zero
                : const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            child: Padding(
              padding: EdgeInsets.only(right: 22 + opened * 14, bottom: 8),
              child: Transform.rotate(
                angle: reduced ? 0 : -.025 * opened,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: c.secondary.withValues(alpha: .2),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
