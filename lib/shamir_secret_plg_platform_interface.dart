import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'shamir_secret_plg_method_channel.dart';

abstract class ShamirSecretPlgPlatform extends PlatformInterface {
  /// Constructs a ShamirSecretPlgPlatform.
  ShamirSecretPlgPlatform() : super(token: _token);

  static final Object _token = Object();

  static ShamirSecretPlgPlatform _instance = MethodChannelShamirSecretPlg();

  /// The default instance of [ShamirSecretPlgPlatform] to use.
  ///
  /// Defaults to [MethodChannelShamirSecretPlg].
  static ShamirSecretPlgPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [ShamirSecretPlgPlatform] when
  /// they register themselves.
  static set instance(ShamirSecretPlgPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
