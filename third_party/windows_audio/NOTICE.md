# Windows audio components

RP Music bundles the Windows x64 Immuch360 build of libmpv from [libmpv-windows-20261110-1](https://github.com/immuch360/libmpv-builds/releases/tag/libmpv-windows-20261110-1), distributed under LGPL-3.0-or-later as built. Windows loads libmpv-2.dll dynamically. Users can replace it with a compatible DLL. RP Music did not modify the native binary.

- mpv revision: 0b7ed670f7c353dd3dd4f8ae0fc788a181a15aa6.
- FFmpeg revision: 5b9a3ad71a4b54979e7afc3a1a4269763c4f41fc.
- DLL SHA-256: 3f026a3263ecb31fd6b0297a865cd68cb65420bd40e338bb487df0e356e1ed8a.
- [Corresponding source with pinned dependencies, patches and build recipe](https://github.com/immuch360/libmpv-builds/releases/download/libmpv-windows-20261110-1/libmpv-windows-20261110-1-sources.tar.xz).
- Corresponding source SHA-256: 3a4c0bea324b3ff12332465965a149fe4aa5a7e007846dc515a93652841d3b21.

The complete upstream license directory and the build report are included under licenses/libmpv beside the application. The wrapper licenses are provided alongside this notice. RP Music uses modified local copies of media_kit_libs_windows_audio 1.0.9 (MIT) and just_audio_media_kit 2.1.0 (Unlicense), plus media_kit 1.2.6 (MIT). The Windows wrapper change pins and bundles the Immuch360 archive and installs its upstream notices.

The historical Windows release of RP Music 0.4.8 originally shipped a different Media Kit audio build. The corresponding-source link above applies to the Immuch360 DLL identified by the SHA-256 above.
