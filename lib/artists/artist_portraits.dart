import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';

import '../app/app_version.dart';
import '../themes/theme_library.dart';

String normalized(String value) {
  var result = value.toLowerCase().trim();
  const accents = 'áàäâéèëêíìïîóòöôúùüûñ';
  const plain = 'aaaaeeeeiiiioooouuuun';
  for (var i = 0; i < accents.length; i++) {
    result = result.replaceAll(accents[i], plain[i]);
  }
  return result
      .replaceAll(RegExp(r'[\u0300-\u036f]'), '')
      .replaceAll(RegExp(r'[^a-z0-9\u0080-\uffff]+'), ' ')
      .trim();
}

class ArtistPortrait {
  const ArtistPortrait(this.file, this.credit);
  final File file;
  final String credit;
}

/// Retrieves only visible artists, retaining the old private cache location.
class ArtistPortraits {
  ArtistPortraits(this.directory, {this.request});
  final Directory directory;
  final Future<Uint8List> Function(Uri uri)? request;
  final _inFlight = <String, Future<ArtistPortrait?>>{};
  final _ready = <String, ArtistPortrait>{};
  Future<void> _queue = Future.value();
  bool _closed = false;
  String? lastError;
  DateTime? _retryNetworkAfter;
  final _clients = <HttpClient>{};

  String key(String name) =>
      sha256.convert(utf8.encode(name.toLowerCase().trim())).toString();

  Future<ArtistPortrait?> photo(String name, {String? trackTitle}) {
    final id = key(name);
    final lookup = '$id-${key(trackTitle ?? '')}';
    final ready = _ready[lookup];
    if (ready != null) return Future.value(ready);
    return _inFlight.putIfAbsent(
      lookup,
      () => _load(name, lookup, trackTitle).whenComplete(() {
        _inFlight.remove(lookup);
      }),
    );
  }

  Future<ArtistPortrait?> _load(
    String name,
    String id,
    String? trackTitle,
  ) async {
    if (_closed || name.trim().isEmpty || name == 'Artista desconocido') {
      return null;
    }
    final file = File('${directory.path}/$id.jpg');
    final metadata = File('${directory.path}/$id.json');
    if (await file.exists()) {
      try {
        final data = jsonDecode(await metadata.readAsString()) as Map;
        if (data['provider'] == 'artist-profile-v4' &&
            data['trackHint'] == (trackTitle ?? '')) {
          return _remember(id, ArtistPortrait(file, data['credit'] as String));
        }
      } catch (_) {
        /* Unverified legacy images are re-resolved, not displayed. */
      }
    }
    final miss = File('${directory.path}/$id.v4.miss.json');
    try {
      final data = jsonDecode(await miss.readAsString()) as Map;
      final until = DateTime.parse(data['until'] as String);
      if (DateTime.now().isBefore(until)) return null;
    } catch (_) {
      /* A missing/corrupt negative cache allows a retry. */
    }
    final result = Completer<ArtistPortrait?>();
    _queue = _queue
        .then((_) async {
          if (_closed ||
              (_retryNetworkAfter?.isAfter(DateTime.now()) ?? false)) {
            result.complete(null);
            return;
          }
          var retry = const Duration(days: 1);
          ArtistPortrait? portrait;
          try {
            lastError = null;
            var image = await _resolve(name, trackTitle: trackTitle);
            if (image != null && !_closed) {
              Uint8List bytes;
              try {
                bytes = await _receive(image.url);
              } catch (_) {
                if (!image.source.startsWith(
                  'https://www.deezer.com/artist/',
                )) {
                  rethrow;
                }
                image = await _wikimedia(name);
                if (image == null) rethrow;
                bytes = await _receive(image.url);
              }
              final codec = await ui.instantiateImageCodec(
                bytes,
                targetWidth: 256,
              );
              try {
                final frame = await codec.getNextFrame();
                try {
                  final png = await frame.image.toByteData(
                    format: ui.ImageByteFormat.png,
                  );
                  if (png != null && !_closed) {
                    await directory.create(recursive: true);
                    final temporary = File('${file.path}.pending');
                    await temporary.writeAsBytes(
                      png.buffer.asUint8List(),
                      flush: true,
                    );
                    await metadata.writeAsString(
                      jsonEncode({
                        'provider': 'artist-profile-v4',
                        'trackHint': trackTitle ?? '',
                        'credit': image.credit,
                        'source': image.source,
                      }),
                    );
                    await temporary.rename(file.path);
                    portrait = _remember(
                      id,
                      ArtistPortrait(file, image.credit),
                    );
                  }
                } finally {
                  frame.image.dispose();
                }
              } finally {
                codec.dispose();
              }
            }
          } catch (error) {
            lastError = error.toString();
            retry = const Duration(minutes: 5);
            _retryNetworkAfter = DateTime.now().add(retry);
          }
          if (portrait == null && !_closed) {
            try {
              await directory.create(recursive: true);
              await miss.writeAsString(
                jsonEncode({
                  'until': DateTime.now().add(retry).toIso8601String(),
                }),
              );
            } catch (_) {
              /* Music remains usable with read-only storage. */
            }
          }
          result.complete(portrait);
        })
        .catchError((Object _) {
          if (!result.isCompleted) result.complete(null);
        });
    return result.future;
  }

  ArtistPortrait _remember(String id, ArtistPortrait image) {
    _ready[id] = image;
    while (_ready.length > 128) {
      _ready.remove(_ready.keys.first);
    }
    return image;
  }

  Future<Map<String, dynamic>> _json(Uri uri) async {
    final data = Map<String, dynamic>.from(
      jsonDecode(utf8.decode(await _receive(uri))) as Map,
    );
    if (data.containsKey('error')) {
      throw const HttpException('Artist metadata unavailable');
    }
    return data;
  }

  Future<bool> _isAlbumCover(int id, Uri photo) async {
    String? imageHash(Uri url) =>
        RegExp(r'/images/(?:artist|cover)/([a-f0-9]{32})/')
            .firstMatch(url.path)
            ?.group(1);
    final hash = imageHash(photo);
    if (hash == null) return false;
    final albums = await _json(
      Uri.https('api.deezer.com', '/artist/$id/albums', {'limit': '25'}),
    );
    return (albums['data'] as List? ?? []).whereType<Map>().any((album) {
      final cover = Uri.tryParse(album['cover_big'] as String? ?? '');
      return cover != null && imageHash(cover) == hash;
    });
  }

  Future<({Uri url, String credit, String source})?> _resolve(
    String name, {
    String? trackTitle,
  }) async {
    if (trackTitle != null && trackTitle.trim().isNotEmpty) {
      try {
        final cleanName = name.replaceAll('"', ' ');
        final cleanTitle = trackTitle.replaceAll('"', ' ');
        final tracks = await _json(
          Uri.https('api.deezer.com', '/search', {
            'q': '$cleanName $cleanTitle',
            'limit': '25',
          }),
        );
        final seen = <int>{};
        for (final entry in (tracks['data'] as List? ?? []).whereType<Map>()) {
          final artist = entry['artist'] as Map?;
          if (artist == null ||
              normalized(artist['name'] as String? ?? '') != normalized(name)) {
            continue;
          }
          final title =
              entry['title_short'] as String? ??
              entry['title'] as String? ??
              '';
          if (normalized(title) != normalized(trackTitle) &&
              normalized(entry['title'] as String? ?? '') !=
                  normalized(trackTitle)) {
            continue;
          }
          final id = artist['id'];
          if (id is! int || id <= 0 || !seen.add(id)) continue;
          final profile = await _json(
            Uri.https('api.deezer.com', '/artist/$id'),
          );
          if (normalized(profile['name'] as String? ?? '') !=
              normalized(name)) {
            continue;
          }
          final url = Uri.tryParse(profile['picture_big'] as String? ?? '');
          if (url?.scheme != 'https' ||
              url?.host != 'cdn-images.dzcdn.net' ||
              url!.path.contains('d41d8cd98f00b204e9800998ecf8427e')) {
            continue;
          }
          if (await _isAlbumCover(id, url)) continue;
          final source = 'https://www.deezer.com/artist/$id';
          return (
            url: url,
            credit:
                '$name · Perfil de Deezer contrastado con $trackTitle · $source',
            source: source,
          );
        }
      } catch (_) {
        /* An unavailable catalog does not authorize an unrelated profile. */
      }
      return _wikimedia(name);
    }
    try {
      final data = await _json(
        Uri.https('api.deezer.com', '/search/artist', {
          'q': name,
          'limit': '25',
        }),
      );
      final matches = (data['data'] as List? ?? [])
          .whereType<Map>()
          .where(
            (entry) =>
                normalized(entry['name'] as String? ?? '') == normalized(name),
          )
          .toList();
      int fans(Map entry) => (entry['nb_fan'] as num?)?.toInt() ?? 0;
      matches.sort((a, b) => fans(b).compareTo(fans(a)));
      for (final entry in matches) {
        final photo = Uri.tryParse(
          entry['picture_big'] as String? ??
              entry['picture_medium'] as String? ??
              '',
        );
        if (photo?.scheme != 'https' ||
            photo?.host != 'cdn-images.dzcdn.net' ||
            photo!.path.contains('d41d8cd98f00b204e9800998ecf8427e')) {
          continue;
        }
        final id = entry['id'];
        if (id is! int || id <= 0) continue;
        if (await _isAlbumCover(id, photo)) continue;
        final source = 'https://www.deezer.com/artist/$id';
        return (
          url: photo,
          credit: '$name · Foto de perfil de Deezer · $source',
          source: source,
        );
      }
    } catch (_) {
      /* Profile service failure does not prevent the Wikimedia fallback. */
    }
    return _wikimedia(name);
  }

  Future<({Uri url, String credit, String source})?> _wikimedia(
    String name, {
    String language = 'en',
  }) async {
    final search = await _json(
      Uri.https('www.wikidata.org', '/w/api.php', {
        'action': 'wbsearchentities',
        'search': name,
        'language': language,
        'format': 'json',
        'limit': '10',
        'maxlag': '5',
      }),
    );
    final candidates = (search['search'] as List? ?? [])
        .whereType<Map>()
        .where((entry) {
          final label = entry['label'] as String? ?? '';
          final matched = (entry['match'] as Map?)?['text'] as String? ?? '';
          return normalized(label) == normalized(name) ||
              normalized(matched) == normalized(name);
        })
        .map((entry) => entry['id'])
        .whereType<String>()
        .where((id) => RegExp(r'^Q\d+$').hasMatch(id))
        .toList();
    if (candidates.isEmpty) {
      return language == 'en' ? _wikimedia(name, language: 'es') : null;
    }
    final data = await _json(
      Uri.https('www.wikidata.org', '/w/api.php', {
        'action': 'wbgetentities',
        'ids': candidates.join('|'),
        'props': 'claims',
        'format': 'json',
        'maxlag': '5',
      }),
    );
    final entities = data['entities'] as Map? ?? {};
    String? filename;
    for (final id in candidates) {
      final claims = (entities[id] as Map?)?['claims'] as Map? ?? {};
      // P434 identifies a musical artist, avoiding films or discographies with the same name.
      Set<String> values(String property) => (claims[property] as List? ?? [])
          .whereType<Map>()
          .map(
            (claim) =>
                ((claim['mainsnak'] as Map?)?['datavalue'] as Map?)?['value'],
          )
          .whereType<Map>()
          .map((value) => value['id'])
          .whereType<String>()
          .toSet();
      final musical =
          (claims['P434'] as List? ?? []).isNotEmpty ||
          values('P106').intersection({
            'Q177220',
            'Q639669',
            'Q225226',
            'Q488205',
            'Q36834',
            'Q1278335',
          }).isNotEmpty ||
          values('P31').intersection({'Q215380', 'Q2088357'}).isNotEmpty;
      if (!musical) continue;
      final photos =
          (claims['P18'] as List? ?? [])
              .whereType<Map>()
              .where((claim) => claim['rank'] != 'deprecated')
              .toList()
            ..sort(
              (a, b) => (b['rank'] == 'preferred' ? 1 : 0).compareTo(
                a['rank'] == 'preferred' ? 1 : 0,
              ),
            );
      for (final claim in photos) {
        final snak = claim['mainsnak'] as Map?;
        final value = (snak?['datavalue'] as Map?)?['value'];
        if (value is String) {
          filename = value;
          break;
        }
      }
      if (filename != null) break;
    }
    if (filename == null) {
      return language == 'en' ? _wikimedia(name, language: 'es') : null;
    }
    final info = await _json(
      Uri.https('commons.wikimedia.org', '/w/api.php', {
        'action': 'query',
        'format': 'json',
        'prop': 'imageinfo',
        'titles': 'File:$filename',
        'iiprop': 'url|extmetadata',
        'iiurlwidth': '256',
      }),
    );
    final pages = (info['query'] as Map?)?['pages'] as Map?;
    for (final page
        in pages?.values.whereType<Map>() ?? const Iterable<Map>.empty()) {
      for (final image in (page['imageinfo'] as List? ?? []).whereType<Map>()) {
        final url = Uri.tryParse(image['thumburl'] as String? ?? '');
        if (!{
              'upload.wikimedia.org',
              'thumb.wikimedia.org',
            }.contains(url?.host) ||
            url?.scheme != 'https') {
          continue;
        }
        final extra = image['extmetadata'] as Map? ?? {};
        String text(String field) =>
            ((extra[field] as Map?)?['value'] as String? ?? '')
                .replaceAll(RegExp('<[^>]*>'), '')
                .replaceAll('&amp;', '&')
                .trim();
        return (
          url: url!,
          credit: [
            name,
            text('Artist'),
            text('LicenseShortName'),
            image['descriptionurl'] as String? ?? '',
          ].where((s) => s.isNotEmpty).join(' · '),
          source: image['descriptionurl'] as String? ?? '',
        );
      }
    }
    return null;
  }

  Future<Uint8List> _receive(Uri uri) async {
    if (request != null) return request!(uri);
    if (_closed) throw StateError('Disposed');
    const hosts = {
      'api.deezer.com',
      'cdn-images.dzcdn.net',
      'www.wikidata.org',
      'commons.wikimedia.org',
      'upload.wikimedia.org',
      'thumb.wikimedia.org',
    };
    if (uri.scheme != 'https' || !hosts.contains(uri.host)) {
      throw const FormatException();
    }
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 8);
    _clients.add(client);
    try {
      return await (() async {
        var target = uri;
        for (var redirect = 0; redirect < 4; redirect++) {
          final request = await client.getUrl(target);
          request.followRedirects = false;
          request.headers.set(
            HttpHeaders.userAgentHeader,
            'RP-Music/$appVersion (https://github.com/Joao-s02/rp_music)',
          );
          final response = await request.close();
          if (response.isRedirect) {
            final location = response.headers.value(HttpHeaders.locationHeader);
            await response.drain<void>();
            if (location == null) throw const FormatException();
            target = target.resolve(location);
            if (target.scheme != 'https' || !hosts.contains(target.host)) {
              throw const FormatException();
            }
            continue;
          }
          if (response.statusCode != 200 ||
              response.contentLength > 2 * 1024 * 1024) {
            throw HttpException(
              'Portrait HTTP ${response.statusCode} (${target.host})',
            );
          }
          final bytes = BytesBuilder(copy: false);
          await for (final chunk in response) {
            if (_closed || bytes.length + chunk.length > 2 * 1024 * 1024) {
              throw const FormatException();
            }
            bytes.add(chunk);
          }
          return bytes.takeBytes();
        }
        throw const FormatException();
      })().timeout(const Duration(seconds: 15));
    } finally {
      client.close(force: true);
      _clients.remove(client);
    }
  }

  void dispose() {
    _closed = true;
    for (final client in _clients) {
      client.close(force: true);
    }
    _clients.clear();
  }
}

class ArtistPhoto extends StatefulWidget {
  const ArtistPhoto({
    super.key,
    required this.artist,
    required this.portraits,
    this.trackTitle,
  });
  final String? trackTitle;
  final String artist;
  final ArtistPortraits portraits;

  @override
  State<ArtistPhoto> createState() => _ArtistPhotoState();
}

class _ArtistPhotoState extends State<ArtistPhoto> {
  late Future<ArtistPortrait?> photo = widget.portraits.photo(
    widget.artist,
    trackTitle: widget.trackTitle,
  );

  @override
  void didUpdateWidget(ArtistPhoto oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.artist != widget.artist ||
        oldWidget.trackTitle != widget.trackTitle ||
        oldWidget.portraits != widget.portraits) {
      photo = widget.portraits.photo(
        widget.artist,
        trackTitle: widget.trackTitle,
      );
    }
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 48,
    height: 48,
    child: FutureBuilder(
      key: ValueKey('${widget.artist}:${widget.trackTitle}'),
      future: photo,
      builder: (context, snapshot) {
        final portrait = snapshot.data;
        const fallback = ThemeIcon('artist', Icons.person_outline);
        if (portrait == null) return fallback;
        return Tooltip(
          message: portrait.credit,
          child: ClipOval(
            child: Image.file(
              portrait.file,
              fit: BoxFit.cover,
              alignment: const Alignment(0, -.65),
              cacheWidth: 144,
              errorBuilder: (_, _, _) => fallback,
            ),
          ),
        );
      },
    ),
  );
}
