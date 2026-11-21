import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../playback/music_handler.dart';

class PlayerKeyboard extends StatelessWidget {
  const PlayerKeyboard({
    super.key,
    required this.audio,
    required this.onEscape,
    required this.child,
    this.onSearch,
    this.expanded = false,
  });

  final MusicHandler audio;
  final bool Function() onEscape;
  final VoidCallback? onSearch;
  final Widget child;
  final bool expanded;

  KeyEventResult handleKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    final repeating = event is KeyRepeatEvent;
    final key = event.logicalKey;
    final keyboard = HardwareKeyboard.instance;
    if (keyboard.isAltPressed ||
        keyboard.isMetaPressed ||
        keyboard.isShiftPressed) {
      return KeyEventResult.ignored;
    }
    if (!repeating &&
        !keyboard.isControlPressed &&
        key == LogicalKeyboardKey.escape) {
      return onEscape() ? KeyEventResult.handled : KeyEventResult.ignored;
    }
    final focus = FocusManager.instance.primaryFocus?.context;
    if (keyboard.isControlPressed &&
        key == LogicalKeyboardKey.keyF &&
        onSearch != null) {
      if (!repeating) onSearch!();
      return KeyEventResult.handled;
    }
    if (focus?.findAncestorWidgetOfExactType<EditableText>() != null) {
      return KeyEventResult.ignored;
    }
    if (key == LogicalKeyboardKey.arrowLeft ||
        key == LogicalKeyboardKey.arrowRight) {
      final forward = key == LogicalKeyboardKey.arrowRight;
      if (keyboard.isControlPressed) {
        if (!repeating) {
          forward ? audio.skipToNext() : audio.skipToPrevious();
        }
      } else if (expanded) {
        final duration = audio.player.duration;
        if (duration != null) {
          final position = audio.player.position.inMilliseconds;
          audio.seek(
            Duration(
              milliseconds: (position + (forward ? 5000 : -5000)).clamp(
                0,
                duration.inMilliseconds,
              ),
            ),
          );
        }
      } else {
        return KeyEventResult.ignored;
      }
      return KeyEventResult.handled;
    }
    if (!keyboard.isControlPressed &&
        key == LogicalKeyboardKey.space &&
        (focus == node.context || focus?.widget is FocusScope)) {
      if (!repeating) audio.player.playing ? audio.pause() : audio.play();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform != TargetPlatform.windows) return child;
    return Focus(autofocus: true, onKeyEvent: handleKey, child: child);
  }
}
