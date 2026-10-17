import 'package:rp_music/features/library/domain/source_resolver.dart';
import 'source_resolver_web.dart'
    if (dart.library.io) 'source_resolver_native.dart' as impl;

SourceResolver getSourceResolver() => impl.createSourceResolver();
