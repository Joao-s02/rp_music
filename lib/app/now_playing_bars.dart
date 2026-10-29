import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Decorative playback indicator, not an audio spectrum measurement.
class NowPlayingBars extends StatefulWidget {
  const NowPlayingBars({super.key, required this.playing, this.size = 26});
  final bool playing;
  final double size;
  @override
  State<NowPlayingBars> createState() => _NowPlayingBarsState();
}

class _NowPlayingBarsState extends State<NowPlayingBars>
    with SingleTickerProviderStateMixin {
  late final motion = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );
  void update() {
    if (widget.playing && !MediaQuery.disableAnimationsOf(context)) {
      if (!motion.isAnimating) motion.repeat();
    } else {
      motion.stop();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    update();
  }

  @override
  void didUpdateWidget(NowPlayingBars old) {
    super.didUpdateWidget(old);
    update();
  }

  @override
  void dispose() {
    motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    label: widget.playing ? 'Reproduciendo' : 'En pausa',
    child: SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: motion,
        builder: (context, _) => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(
            4,
            (i) => Container(
              width: widget.size / 8,
              margin: EdgeInsets.symmetric(horizontal: widget.size / 32),
              height:
                  widget.size *
                  (widget.playing
                      ? .28 +
                            .65 *
                                (math
                                    .sin(motion.value * math.pi * 2 + i * 1.7)
                                    .abs())
                      : .28),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
