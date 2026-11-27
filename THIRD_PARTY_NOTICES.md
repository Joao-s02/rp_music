# Avisos de terceros de RP Music

## Recursos incluidos

| Componente | Licencia y atribución |
| --- | --- |
| Inter | SIL OFL 1.1. Texto y copyright en [Inter-OFL.txt](assets/fonts/Inter-OFL.txt). |
| Plus Jakarta Sans | SIL OFL 1.1. Texto y copyright en [PlusJakartaSans-OFL.txt](assets/fonts/PlusJakartaSans-OFL.txt). |
| Material Icons | Google, Apache-2.0. [Texto de licencia](assets/licenses/Apache-2.0.txt). Flutter proporciona la fuente y puede subconjuntar los glifos durante la compilación. |
| hls.js 1.4.10 | Dailymotion y colaboradores. [Apache-2.0](assets/licenses/Apache-2.0.txt) y atribuciones upstream en el [aviso de hls.js](assets/licenses/hls.js-1.4.10-LICENSE.txt). [Fuente de la versión](https://github.com/video-dev/hls.js/tree/v1.4.10). Media Kit empaqueta el JavaScript en Android y Windows. |

## Componentes de plataforma

- **Android** incluye Flutter, Dart JNI y Media3. El [inventario y los avisos de Android](android/app/src/main/assets/licenses/ANDROID-THIRD-PARTY-NOTICES.md) se incluyen en los APK dentro de `assets/licenses/`.
- **Windows** incluye Flutter, Dart JNI, Media Kit y libmpv. Consulta el [aviso de audio Windows](third_party/windows_audio/NOTICE.md) y los textos en ese directorio. La fuente correspondiente de la DLL incluida en 0.4.8 sigue pendiente.
- **Motor Flutter**. El SDK auditado corresponde a Flutter 3.47.6 y Dart 3.13.5. Los paquetes compilados contienen el archivo generado `NOTICES.Z` con textos de Flutter y de dependencias. Este inventario complementa ese archivo.
- **Copias modificadas**. Consulta los parches de [audio_service](third_party/audio_service/RP-MUSIC-PATCH.md), [just_audio](third_party/just_audio/RP-MUSIC-PATCH.md) y [just_audio_media_kit](third_party/just_audio_media_kit/RP-MUSIC-PATCH.md). Sus textos de licencia se conservan junto al código y en los avisos generados.

## Dependencias bloqueadas de Flutter y Dart

Inventario de `pubspec.lock` para 0.4.8. Incluye dependencias de desarrollo y de otras plataformas. Para paquetes Pub, la versión enlazada contiene el texto y las atribuciones del paquete. El SDK Flutter incluye componentes con avisos propios.

| Paquete | Versión | Alcance | Licencia principal |
| --- | --- | --- | --- |
| [android_file_picker](https://pub.dev/packages/android_file_picker/versions/2.1.1/license) | 2.1.1 | Transitiva | MIT |
| [archive](https://pub.dev/packages/archive/versions/4.5.2/license) | 4.5.2 | Transitiva | MIT |
| [args](https://pub.dev/packages/args/versions/2.7.0/license) | 2.7.0 | Transitiva | BSD |
| [async](https://pub.dev/packages/async/versions/2.13.1/license) | 2.13.1 | Transitiva | BSD |
| [audio_metadata_reader](https://pub.dev/packages/audio_metadata_reader/versions/1.8.1/license) | 1.8.1 | Directa | MIT |
| [audio_service](third_party/audio_service/LICENSE) | 0.18.19 | Directa | MIT |
| [audio_service_platform_interface](https://pub.dev/packages/audio_service_platform_interface/versions/0.1.3/license) | 0.1.3 | Transitiva | MIT |
| [audio_service_web](https://pub.dev/packages/audio_service_web/versions/0.1.4/license) | 0.1.4 | Transitiva | MIT |
| [audio_session](https://pub.dev/packages/audio_session/versions/0.2.4/license) | 0.2.4 | Directa | MIT |
| [boolean_selector](https://pub.dev/packages/boolean_selector/versions/2.1.2/license) | 2.1.2 | Transitiva | BSD |
| [characters](https://pub.dev/packages/characters/versions/1.4.1/license) | 1.4.1 | Transitiva | BSD |
| [charset](https://pub.dev/packages/charset/versions/2.0.1/license) | 2.0.1 | Transitiva | Apache-2.0 |
| [clock](https://pub.dev/packages/clock/versions/1.1.3/license) | 1.1.3 | Transitiva | Apache-2.0 |
| [code_assets](https://pub.dev/packages/code_assets/versions/2.1.0/license) | 2.1.0 | Transitiva | BSD |
| [collection](https://pub.dev/packages/collection/versions/1.19.1/license) | 1.19.1 | Transitiva | BSD |
| [cross_file](https://pub.dev/packages/cross_file/versions/0.3.5+5/license) | 0.3.5+5 | Transitiva | BSD |
| [crypto](https://pub.dev/packages/crypto/versions/3.0.7/license) | 3.0.7 | Directa | BSD |
| [dbus](https://pub.dev/packages/dbus/versions/0.8.0/license) | 0.8.0 | Transitiva | MPL-2.0 |
| [fake_async](https://pub.dev/packages/fake_async/versions/1.3.3/license) | 1.3.3 | Transitiva | Apache-2.0 |
| [ffi](https://pub.dev/packages/ffi/versions/2.2.0/license) | 2.2.0 | Transitiva | BSD |
| [ffi_leak_tracker](https://pub.dev/packages/ffi_leak_tracker/versions/0.1.2/license) | 0.1.2 | Transitiva | BSD |
| [file](https://pub.dev/packages/file/versions/7.0.1/license) | 7.0.1 | Transitiva | BSD |
| [file_picker](https://pub.dev/packages/file_picker/versions/13.1.0/license) | 13.1.0 | Directa | MIT |
| [file_picker_darwin](https://pub.dev/packages/file_picker_darwin/versions/2.3.2/license) | 2.3.2 | Transitiva | MIT |
| [file_picker_linux](https://pub.dev/packages/file_picker_linux/versions/2.0.2/license) | 2.0.2 | Transitiva | MIT |
| [file_picker_platform_interface](https://pub.dev/packages/file_picker_platform_interface/versions/4.2.0/license) | 4.2.0 | Transitiva | MIT |
| [file_picker_web](https://pub.dev/packages/file_picker_web/versions/4.2.0/license) | 4.2.0 | Transitiva | MIT |
| [fixnum](https://pub.dev/packages/fixnum/versions/1.1.1/license) | 1.1.1 | Transitiva | BSD |
| [flutter](https://github.com/flutter/flutter/tree/5fc346839b5d0eef006ed8404392afb4dfae428d) | 0.0.0 | Directa | SDK Flutter |
| [flutter_cache_manager](https://pub.dev/packages/flutter_cache_manager/versions/3.4.5/license) | 3.4.5 | Transitiva | MIT |
| [flutter_driver](https://github.com/flutter/flutter/tree/5fc346839b5d0eef006ed8404392afb4dfae428d) | 0.0.0 | Transitiva | SDK Flutter |
| [flutter_lints](https://pub.dev/packages/flutter_lints/versions/6.0.0/license) | 6.0.0 | Desarrollo | BSD |
| [flutter_test](https://github.com/flutter/flutter/tree/5fc346839b5d0eef006ed8404392afb4dfae428d) | 0.0.0 | Desarrollo | SDK Flutter |
| [flutter_web_plugins](https://github.com/flutter/flutter/tree/5fc346839b5d0eef006ed8404392afb4dfae428d) | 0.0.0 | Transitiva | SDK Flutter |
| [fuchsia_remote_debug_protocol](https://github.com/flutter/flutter/tree/5fc346839b5d0eef006ed8404392afb4dfae428d) | 0.0.0 | Transitiva | SDK Flutter |
| [hooks](https://pub.dev/packages/hooks/versions/2.2.0/license) | 2.2.0 | Transitiva | BSD |
| [http](https://pub.dev/packages/http/versions/1.6.0/license) | 1.6.0 | Transitiva | BSD |
| [http_parser](https://pub.dev/packages/http_parser/versions/4.1.2/license) | 4.1.2 | Transitiva | BSD |
| [image](https://pub.dev/packages/image/versions/4.12.0/license) | 4.12.0 | Transitiva | MIT |
| [integration_test](https://github.com/flutter/flutter/tree/5fc346839b5d0eef006ed8404392afb4dfae428d) | 0.0.0 | Desarrollo | SDK Flutter |
| [intl](https://pub.dev/packages/intl/versions/0.20.3/license) | 0.20.3 | Transitiva | BSD |
| [jni](https://pub.dev/packages/jni/versions/1.1.0/license) | 1.1.0 | Transitiva | BSD |
| [jni_flutter](https://pub.dev/packages/jni_flutter/versions/1.0.4+1/license) | 1.0.4+1 | Transitiva | BSD |
| [jni_util](https://pub.dev/packages/jni_util/versions/1.0.0/license) | 1.0.0 | Transitiva | BSD |
| [js](https://pub.dev/packages/js/versions/0.7.2/license) | 0.7.2 | Transitiva | BSD |
| [just_audio](third_party/just_audio/LICENSE) | 0.10.6 | Directa, [copia modificada](third_party/just_audio/RP-MUSIC-PATCH.md) | MIT; ExoPlayer Apache-2.0 |
| [just_audio_media_kit](third_party/just_audio_media_kit/LICENSE) | 2.1.0 | Directa | Unlicense |
| [just_audio_platform_interface](https://pub.dev/packages/just_audio_platform_interface/versions/4.6.0/license) | 4.6.0 | Transitiva | MIT |
| [just_audio_web](https://pub.dev/packages/just_audio_web/versions/0.4.16/license) | 0.4.16 | Transitiva | MIT |
| [leak_tracker](https://pub.dev/packages/leak_tracker/versions/11.0.2/license) | 11.0.2 | Transitiva | BSD |
| [leak_tracker_flutter_testing](https://pub.dev/packages/leak_tracker_flutter_testing/versions/3.0.10/license) | 3.0.10 | Transitiva | BSD |
| [leak_tracker_testing](https://pub.dev/packages/leak_tracker_testing/versions/3.0.2/license) | 3.0.2 | Transitiva | BSD |
| [lints](https://pub.dev/packages/lints/versions/6.1.0/license) | 6.1.0 | Transitiva | BSD |
| [logging](https://pub.dev/packages/logging/versions/1.3.0/license) | 1.3.0 | Transitiva | BSD |
| [matcher](https://pub.dev/packages/matcher/versions/0.12.20/license) | 0.12.20 | Transitiva | BSD |
| [material_color_utilities](https://pub.dev/packages/material_color_utilities/versions/0.13.0/license) | 0.13.0 | Transitiva | Apache-2.0 |
| [media_kit](https://pub.dev/packages/media_kit/versions/1.2.6/license) | 1.2.6 | Transitiva | MIT |
| [media_kit_libs_windows_audio](https://pub.dev/packages/media_kit_libs_windows_audio/versions/1.0.9/license) | 1.0.9 | Directa | MIT |
| [meta](https://pub.dev/packages/meta/versions/1.19.0/license) | 1.19.0 | Transitiva | BSD |
| [mime](https://pub.dev/packages/mime/versions/2.1.0/license) | 2.1.0 | Transitiva | BSD |
| [objective_c](https://pub.dev/packages/objective_c/versions/9.6.2/license) | 9.6.2 | Transitiva | BSD |
| [package_config](https://pub.dev/packages/package_config/versions/2.2.0/license) | 2.2.0 | Transitiva | BSD |
| [path](https://pub.dev/packages/path/versions/1.9.1/license) | 1.9.1 | Directa | BSD |
| [path_provider](https://pub.dev/packages/path_provider/versions/2.1.6/license) | 2.1.6 | Directa | BSD |
| [path_provider_android](https://pub.dev/packages/path_provider_android/versions/2.3.1/license) | 2.3.1 | Transitiva | BSD |
| [path_provider_foundation](https://pub.dev/packages/path_provider_foundation/versions/2.6.0/license) | 2.6.0 | Transitiva | BSD |
| [path_provider_linux](https://pub.dev/packages/path_provider_linux/versions/2.2.2/license) | 2.2.2 | Transitiva | BSD |
| [path_provider_platform_interface](https://pub.dev/packages/path_provider_platform_interface/versions/2.1.3/license) | 2.1.3 | Transitiva | BSD |
| [path_provider_windows](https://pub.dev/packages/path_provider_windows/versions/2.3.0/license) | 2.3.0 | Transitiva | BSD |
| [petitparser](https://pub.dev/packages/petitparser/versions/7.1.0/license) | 7.1.0 | Transitiva | MIT |
| [platform](https://pub.dev/packages/platform/versions/3.2.0/license) | 3.2.0 | Transitiva | BSD |
| [plugin_platform_interface](https://pub.dev/packages/plugin_platform_interface/versions/2.1.8/license) | 2.1.8 | Transitiva | BSD |
| [posix](https://pub.dev/packages/posix/versions/6.5.4/license) | 6.5.4 | Transitiva | MIT |
| [process](https://pub.dev/packages/process/versions/5.0.6/license) | 5.0.6 | Transitiva | BSD |
| [pub_semver](https://pub.dev/packages/pub_semver/versions/2.2.1/license) | 2.2.1 | Transitiva | BSD |
| [record_use](https://pub.dev/packages/record_use/versions/1.1.1/license) | 1.1.1 | Transitiva | BSD |
| [rxdart](https://pub.dev/packages/rxdart/versions/0.28.0/license) | 0.28.0 | Transitiva | Apache-2.0 |
| [safe_local_storage](https://pub.dev/packages/safe_local_storage/versions/2.0.7/license) | 2.0.7 | Transitiva | MIT |
| [sky_engine](https://github.com/flutter/flutter/tree/5fc346839b5d0eef006ed8404392afb4dfae428d) | 0.0.0 | Transitiva | SDK Flutter |
| [source_span](https://pub.dev/packages/source_span/versions/1.10.2/license) | 1.10.2 | Transitiva | BSD |
| [sqflite](https://pub.dev/packages/sqflite/versions/2.4.4+2/license) | 2.4.4+2 | Transitiva | BSD |
| [sqflite_android](https://pub.dev/packages/sqflite_android/versions/2.4.4+1/license) | 2.4.4+1 | Transitiva | BSD |
| [sqflite_common](https://pub.dev/packages/sqflite_common/versions/2.5.14/license) | 2.5.14 | Transitiva | BSD |
| [sqflite_darwin](https://pub.dev/packages/sqflite_darwin/versions/2.4.4+1/license) | 2.4.4+1 | Transitiva | BSD |
| [sqflite_platform_interface](https://pub.dev/packages/sqflite_platform_interface/versions/2.4.2/license) | 2.4.2 | Transitiva | BSD |
| [stack_trace](https://pub.dev/packages/stack_trace/versions/1.12.2/license) | 1.12.2 | Transitiva | BSD |
| [stream_channel](https://pub.dev/packages/stream_channel/versions/2.1.4/license) | 2.1.4 | Transitiva | BSD |
| [string_scanner](https://pub.dev/packages/string_scanner/versions/1.4.1/license) | 1.4.1 | Transitiva | BSD |
| [sync_http](https://pub.dev/packages/sync_http/versions/0.3.1/license) | 0.3.1 | Transitiva | BSD |
| [synchronized](https://pub.dev/packages/synchronized/versions/3.5.0/license) | 3.5.0 | Transitiva | MIT |
| [term_glyph](https://pub.dev/packages/term_glyph/versions/1.2.2/license) | 1.2.2 | Transitiva | BSD |
| [test_api](https://pub.dev/packages/test_api/versions/0.7.12/license) | 0.7.12 | Transitiva | BSD |
| [typed_data](https://pub.dev/packages/typed_data/versions/1.4.0/license) | 1.4.0 | Transitiva | BSD |
| [universal_platform](https://pub.dev/packages/universal_platform/versions/1.1.0/license) | 1.1.0 | Transitiva | MIT |
| [uri_parser](https://pub.dev/packages/uri_parser/versions/3.0.2/license) | 3.0.2 | Transitiva | MIT |
| [uuid](https://pub.dev/packages/uuid/versions/4.6.0/license) | 4.6.0 | Transitiva | MIT |
| [vector_math](https://pub.dev/packages/vector_math/versions/2.4.0/license) | 2.4.0 | Transitiva | BSD |
| [vm_service](https://pub.dev/packages/vm_service/versions/15.4.0/license) | 15.4.0 | Transitiva | BSD |
| [web](https://pub.dev/packages/web/versions/1.1.1/license) | 1.1.1 | Transitiva | BSD |
| [webdriver](https://pub.dev/packages/webdriver/versions/3.1.0/license) | 3.1.0 | Transitiva | Apache-2.0 |
| [win32](https://pub.dev/packages/win32/versions/6.4.0/license) | 6.4.0 | Transitiva | BSD |
| [windows_file_picker](https://pub.dev/packages/windows_file_picker/versions/2.0.1/license) | 2.0.1 | Transitiva | MIT |
| [xdg_directories](https://pub.dev/packages/xdg_directories/versions/1.1.0/license) | 1.1.0 | Transitiva | BSD |
| [xml](https://pub.dev/packages/xml/versions/6.6.1/license) | 6.6.1 | Transitiva | MIT |
| [yaml](https://pub.dev/packages/yaml/versions/3.1.4/license) | 3.1.4 | Transitiva | MIT |
