import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'shamir_secret_plg_platform_interface.dart';

/// An implementation of [ShamirSecretPlgPlatform] that uses method channels.
class MethodChannelShamirSecretPlg extends ShamirSecretPlgPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('shamir_secret_plg');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
