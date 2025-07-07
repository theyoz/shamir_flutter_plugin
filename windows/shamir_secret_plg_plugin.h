#ifndef FLUTTER_PLUGIN_SHAMIR_SECRET_PLG_PLUGIN_H_
#define FLUTTER_PLUGIN_SHAMIR_SECRET_PLG_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace shamir_secret_plg {

class ShamirSecretPlgPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  ShamirSecretPlgPlugin();

  virtual ~ShamirSecretPlgPlugin();

  // Disallow copy and assign.
  ShamirSecretPlgPlugin(const ShamirSecretPlgPlugin&) = delete;
  ShamirSecretPlgPlugin& operator=(const ShamirSecretPlgPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace shamir_secret_plg

#endif  // FLUTTER_PLUGIN_SHAMIR_SECRET_PLG_PLUGIN_H_
