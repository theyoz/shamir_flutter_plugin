
import 'shamir_secret_plg_platform_interface.dart';

class ShamirSecretPlg {
  Future<String?> getPlatformVersion() {
    return ShamirSecretPlgPlatform.instance.getPlatformVersion();
  }
}
