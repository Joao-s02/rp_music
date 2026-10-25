import 'package:flutter/material.dart';

import '../playback/music_handler.dart';
import 'library_controller.dart';

class VolumeControl extends StatefulWidget {
  const VolumeControl({super.key, required this.audio, required this.library});
  final MusicHandler audio;
  final LibraryController library;
  @override
  State<VolumeControl> createState() => _VolumeControlState();
}

class _VolumeControlState extends State<VolumeControl> {
  double _lastAudible = 1;
  @override
  Widget build(BuildContext context) => StreamBuilder<double>(
    stream: widget.audio.player.volumeStream,
    initialData: widget.audio.player.volume,
    builder: (context, snapshot) {
      final volume = (snapshot.data ?? 1).clamp(0.0, 1.0);
      return Row(
        children: [
          IconButton(
            tooltip: volume == 0 ? 'Activar sonido' : 'Silenciar',
            icon: Icon(volume == 0 ? Icons.volume_off : Icons.volume_up),
            onPressed: () {
              if (volume > 0) _lastAudible = volume;
              final next = volume == 0 ? _lastAudible : 0.0;
              widget.audio.setAppVolume(next);
              widget.library.setVolume(next);
            },
          ),
          Expanded(
            child: Slider(
              semanticFormatterCallback: (value) =>
                  'Volumen ${(value * 100).round()} por ciento',
              value: volume,
              label: '${(volume * 100).round()}%',
              onChanged: widget.audio.setAppVolume,
              onChangeEnd: widget.library.setVolume,
            ),
          ),
        ],
      );
    },
  );
}
