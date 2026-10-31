import 'package:flutter_test/flutter_test.dart';
import 'package:rp_music/domain/track.dart';
import 'package:rp_music/platform/media_tools.dart';

void main() {
  test('handoff preserves selected local track and original lyrics', () {
    const track = Track(id: 'content://music/42', title: 'Canción', folder: '');
    final request = MediaToolRequest(track, '[00:01.00]Letra').toJson();
    expect(request['protocol'], 1);
    expect(request['audioId'], track.id);
    expect(request['lyrics'], '[00:01.00]Letra');
  });
  test('remote sources require a local download before handoff', () {
    const track = Track(
      id: 'remote:42',
      title: 'Canción',
      folder: '',
      sourceId: 'source',
    );
    expect(
      () => const MediaToolRequest(track, '').toJson(),
      throwsFormatException,
    );
  });
}
