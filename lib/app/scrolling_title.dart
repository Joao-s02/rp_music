import 'package:flutter/material.dart';

/// Scroll only overflowing titles, respecting the system's reduced motion setting.
class ScrollingTitle extends StatefulWidget {
  const ScrollingTitle({super.key, required this.text, this.style});
  final String text;
  final TextStyle? style;
  @override
  State<ScrollingTitle> createState() => _ScrollingTitleState();
}

class _ScrollingTitleState extends State<ScrollingTitle>
    with SingleTickerProviderStateMixin {
  late final AnimationController motion = AnimationController(vsync: this);
  double lastDistance = -1;
  String lastText = '';
  @override
  void dispose() {
    motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final style = DefaultTextStyle.of(context).style.merge(widget.style);
      final painter = TextPainter(
        text: TextSpan(text: widget.text, style: style),
        maxLines: 1,
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
      )..layout();
      final distance = (painter.width - constraints.maxWidth).clamp(
        0.0,
        double.infinity,
      );
      final height = painter.height;
      painter.dispose();
      final reduced = MediaQuery.disableAnimationsOf(context);
      if (distance != lastDistance || widget.text != lastText || reduced) {
        lastDistance = distance;
        lastText = widget.text;
        motion.stop();
        motion.value = 0;
        if (distance > 0 && !reduced) {
          motion.duration = Duration(
            milliseconds: (distance / 30 * 1000 + 2400).round(),
          );
          motion.repeat(reverse: true);
        }
      } else if (distance > 0 && !reduced && !motion.isAnimating) {
        motion.repeat(reverse: true);
      }
      if (distance == 0 || reduced) {
        return Text(
          widget.text,
          style: widget.style,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        );
      }
      return Semantics(
        label: widget.text,
        child: ExcludeSemantics(
          child: ClipRect(
            child: SizedBox(
              height: height,
              child: AnimatedBuilder(
                animation: motion,
                builder: (context, _) {
                  final progress = ((motion.value - .15) / .7).clamp(0.0, 1.0);
                  return OverflowBox(
                    alignment: Alignment.centerLeft,
                    maxWidth: double.infinity,
                    child: Transform.translate(
                      offset: Offset(-distance * progress, 0),
                      child: Text(
                        widget.text,
                        style: widget.style,
                        maxLines: 1,
                        softWrap: false,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );
    },
  );
}
