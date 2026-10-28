import 'package:flutter/material.dart';

import '../playback/music_handler.dart';

/// Only the artwork/mini-player owns this gesture; sliders keep their drag.
class TrackSwipe extends StatefulWidget {
  const TrackSwipe({super.key, required this.audio, required this.child});
  final MusicHandler audio;
  final Widget child;
  @override
  State<TrackSwipe> createState() => _TrackSwipeState();
}

class _TrackSwipeState extends State<TrackSwipe> {
  double distance = 0;
  bool changing = false;
  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.translucent,
    onHorizontalDragStart: (_) => distance = 0,
    onHorizontalDragUpdate: (event) => distance += event.delta.dx,
    onHorizontalDragEnd: (event) async {
      if (changing || widget.audio.mediaItem.value == null) return;
      final velocity = event.primaryVelocity ?? 0;
      if (distance.abs() < 64 && velocity.abs() < 650) return;
      final next = distance.abs() >= 64 ? distance < 0 : velocity < 0;
      changing = true;
      try {
        if (next) {
          await widget.audio.skipToNext();
        } else {
          await widget.audio.skipToPrevious();
        }
      } finally {
        changing = false;
      }
    },
    child: widget.child,
  );
}
