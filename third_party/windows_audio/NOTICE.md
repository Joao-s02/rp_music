# Windows audio components

RP Music0.3.10 uses just_audio_media_kit2.1.0 (Unlicense), media_kit1.2.6 (MIT) and media_kit_libs_windows_audio1.0.9 (MIT wrapper). Their license texts are provided alongside this notice.

Windows loads libmpv-2.dll dynamically. The bundled audio-only binary is the upstream2023-09-24 build (652a1dd), downloaded by the package build system from:
https://github.com/media-kit/libmpv-win32-audio-build/releases/tag/2023-09-24
https://github.com/media-kit/libmpv-win32-audio-cmake

Core upstream source and license information:
https://github.com/mpv-player/mpv
https://ffmpeg.org/

The binary's embedded libavcodec/libavformat/libswscale notices identify LGPL version3 or later. The configuration includes --disable-gpl --disable-nonfree --enable-version3. GPL3/LGPL3 texts and LGPL2.1 text for the configurable upstream components are supplied; the MIT wrapper license does not replace the native dependencies' terms. Build scripts and source references above identify the upstream binary; no native library was modified by RP Music. A compatible user-provided libmpv-2.dll can replace the dynamically loaded binary.

Audio-only FFmpeg build, no user music or credentials bundled. Android continues to use the existing just_audio platform engine and audio_service local patches.

Bundled libmpv-2.dll SHA256: 0a5a0b476866c91a639a4e511e8153968f8fa23564461b0aa09acdba816164a4
