//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <charset_converter/charset_converter_plugin.h>
#include <desktop_window/desktop_window_plugin.h>
#include <flutter_secure_storage_windows/flutter_secure_storage_windows_plugin.h>
#include <window_size/window_size_plugin.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  CharsetConverterPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("CharsetConverterPlugin"));
  DesktopWindowPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("DesktopWindowPlugin"));
  FlutterSecureStorageWindowsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FlutterSecureStorageWindowsPlugin"));
  WindowSizePluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("WindowSizePlugin"));
}
