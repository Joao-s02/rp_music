import 'package:rp_music/features/metadata/domain/metadata_reader.dart';
import 'audio_metadata_reader_web.dart'
    if (dart.library.io) 'audio_metadata_reader_native.dart' as impl;

MetadataReader getMetadataReader() => impl.createMetadataReader();
