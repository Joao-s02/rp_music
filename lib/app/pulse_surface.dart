import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Five grooves echo the five bars of the RP identity. Motion is finite and
/// reacts to entering/focusing a collection, rather than running offscreen.
class PulseSurface extends StatefulWidget {
  const PulseSurface({
    super.key,
    required this.child,
    this.index = 0,
    this.inset = const EdgeInsets.all(4),
  });
  final Widget child;
  final int index;
  final EdgeInsets inset;
  @override
  State<PulseSurface> createState() => _PulseSurfaceState();
}

class _PulseSurfaceState extends State<PulseSurface> {
  bool engaged = false;
  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.disableAnimationsOf(context);
    final colors = Theme.of(context).colorScheme;
    return MouseRegion(
      onEnter: (_) => setState(() => engaged = true),
      onExit: (_) => setState(() => engaged = false),
      child: Listener(
        onPointerDown: (_) => setState(() => engaged = true),
        onPointerUp: (_) => setState(() => engaged = false),
        onPointerCancel: (_) => setState(() => engaged = false),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: reduced ? 1 : 0, end: 1),
          duration: reduced
              ? Duration.zero
              : Duration(milliseconds: 650 + math.min(widget.index, 5) * 65),
          curve: Curves.easeOutCubic,
          builder: (context, reveal, _) => Transform.translate(
            offset: Offset(0, (1 - reveal) * 18),
            child: AnimatedContainer(
              duration: reduced
                  ? Duration.zero
                  : const Duration(milliseconds: 420),
              curve: Curves.easeOutCubic,
              transform: Matrix4.diagonal3Values(
                engaged && !reduced ? .986 : 1,
                engaged && !reduced ? .986 : 1,
                1,
              ),
              transformAlignment: Alignment.center,
              child: CustomPaint(
                foregroundPainter: _Grooves(
                  colors.primary,
                  colors.secondary,
                  reveal,
                  engaged,
                  widget.inset,
                ),
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Grooves extends CustomPainter {
  _Grooves(this.cyan, this.violet, this.reveal, this.engaged, this.inset);
  final EdgeInsets inset;
  final Color cyan, violet;
  final double reveal;
  final bool engaged;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRRect(
      RRect.fromRectAndRadius(
        inset.deflateRect(Offset.zero & size),
        const Radius.circular(24),
      ),
    );
    final center = Offset(size.width - inset.right + 14, size.height * .18);
    for (var i = 0; i < 5; i++) {
      final radius = 30.0 + i * 11 + (1 - reveal) * 22;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = i == 2 ? 2 : 1
        ..color = Color.lerp(
          cyan,
          violet,
          i / 4,
        )!.withValues(alpha: (engaged ? .35 : .14) * reveal);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        math.pi * .56,
        math.pi * .94,
        false,
        paint,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_Grooves old) =>
      old.reveal != reveal ||
      old.engaged != engaged ||
      old.cyan != cyan ||
      old.violet != violet;
}
