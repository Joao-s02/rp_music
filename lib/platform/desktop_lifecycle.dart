import 'dart:io';
import 'dart:async';

import 'package:flutter/services.dart';

import '../app/library_controller.dart';
import '../playback/music_handler.dart';

abstract class DesktopWindow {
  Future<bool> initialize(Future<void> Function(String) handler);
  Future<void> hide();
  Future<void> finishClose();
}

class NativeDesktopWindow implements DesktopWindow {
  static const channel = MethodChannel('rp_music/desktop');
  @override
  Future<bool> initialize(Future<void> Function(String) handler) async {
    if (!Platform.isWindows) return false;
    channel.setMethodCallHandler((call) => handler(call.method));
    return await channel.invokeMethod<bool>('initialize') ?? false;
  }

  @override
  Future<void> hide() => channel.invokeMethod<void>('hide');
  @override
  Future<void> finishClose() => channel.invokeMethod<void>('finishClose');
}

class DesktopLifecycle {
  DesktopLifecycle(this.window, this.library, this.audio);
  final DesktopWindow window;
  final LibraryController library;
  final MusicHandler audio;
  bool hasTray = false;
  Future<void>? _quitting;
  Future<void> initialize() async {
    hasTray = await window.initialize(handle);
  }

  Future<void> handle(String event) async {
    if (_quitting != null) return _quitting;
    switch (event) {
      case 'closeRequested':
        if (library.closeToTray && hasTray) {
          try {
            await window.hide();
          } on PlatformException {
            await quit();
          }
        } else {
          await quit();
        }
      case 'quitRequested':
        await quit();
      case 'togglePlayback':
        if (audio.player.playing) {
          await audio.pause();
        } else if (audio.index >= 0) {
          unawaited(audio.play());
        }
    }
  }

  Future<void> quit() => _quitting ??= _quit();
  Future<void> _quit() async {
    try {
      await audio.close();
    } finally {
      await window.finishClose();
    }
  }
}
