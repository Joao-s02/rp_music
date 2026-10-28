//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <flutter_qjs_next/flutter_qjs_plugin.h>
#include <media_kit_libs_windows_audio/media_kit_libs_windows_audio_plugin_c_api.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  FlutterQjsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FlutterQjsPlugin"));
  MediaKitLibsWindowsAudioPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("MediaKitLibsWindowsAudioPluginCApi"));
}
