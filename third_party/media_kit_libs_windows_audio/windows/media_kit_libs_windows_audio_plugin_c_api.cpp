#include "include/media_kit_libs_windows_audio/media_kit_libs_windows_audio_plugin_c_api.h"

#include <iostream>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

void MediaKitLibsWindowsAudioPluginCApiRegisterWithRegistrar(FlutterDesktopPluginRegistrarRef registrar) {
  std::cout << "package:media_kit_libs_windows_audio registered." << std::endl;
  auto* plugin_registrar =
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar);
  flutter::MethodChannel<flutter::EncodableValue> equalizer(
      plugin_registrar->messenger(), "rp_music/equalizer",
      &flutter::StandardMethodCodec::GetInstance());
  equalizer.SetMethodCallHandler([](const auto& call, auto result) {
    if (call.method_name() != "hasDynamicsFilters") {
      result->NotImplemented();
      return;
    }
#ifdef RP_MUSIC_HAS_DYNAMICS_FILTERS
    constexpr bool available = true;
#else
    constexpr bool available = false;
#endif
    result->Success(flutter::EncodableValue(available));
  });
}
