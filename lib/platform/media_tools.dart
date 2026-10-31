import 'dart:io';

import 'package:flutter/services.dart';

import '../domain/track.dart';

/// Versioned handoff shared by native companion adapters. No editor code here.
class MediaToolRequest {
  const MediaToolRequest(this.track, this.lyrics);
  final Track track;
  final String lyrics;

  Map<String, Object?> toJson() {
    if (track.sourceId != null) {
      throw const FormatException(
        'Descarga primero la canción para editar una copia local.',
      );
    }
    if (lyrics.length > 262144) {
      throw const FormatException('La letra supera el tamaño permitido.');
    }
    return {
      'protocol': 1,
      'title': track.title,
      'artist': track.artist,
      'audioId': track.id,
      'artwork': track.artwork,
      'lyrics': lyrics,
    };
  }
}

class MediaTool {
  const MediaTool(this.id, this.name);
  final String id, name;
}

abstract interface class MediaToolPlatform {
  Future<List<MediaTool>> installed();
  Future<void> open(MediaTool tool, MediaToolRequest request);
}

class NativeMediaTools implements MediaToolPlatform {
  const NativeMediaTools();
  static const _channel = MethodChannel('rp_music/media_tools');

  @override
  Future<List<MediaTool>> installed() async {
    // Windows keeps the same request contract; the companion port will supply
    // its launcher. Never claim Android package discovery works on Windows.
    if (!Platform.isAndroid) return const [];
    final rows = await _channel.invokeListMethod<dynamic>('installed') ?? [];
    return rows.map((row) {
      final item = Map<String, dynamic>.from(row as Map);
      return MediaTool(item['id'] as String, item['name'] as String);
    }).toList();
  }

  @override
  Future<void> open(MediaTool tool, MediaToolRequest request) async {
    if (!Platform.isAndroid) {
      throw const FormatException(
        'El editor para Windows todavía no está disponible.',
      );
    }
    await _channel.invokeMethod<void>('open', {
      'tool': tool.id,
      'request': request.toJson(),
    });
  }
}
