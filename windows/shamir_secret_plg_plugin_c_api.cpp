#include "include/shamir_secret_plg/shamir_secret_plg_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "shamir_secret_plg_plugin.h"

void ShamirSecretPlgPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  shamir_secret_plg::ShamirSecretPlgPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
