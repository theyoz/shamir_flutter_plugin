import 'package:flutter_test/flutter_test.dart';
import 'package:shamir_secret_plg/shamir_secret_plg.dart';
import 'package:shamir_secret_plg/shamir_secret_plg_platform_interface.dart';
import 'package:shamir_secret_plg/shamir_secret_plg_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockShamirSecretPlgPlatform
    with MockPlatformInterfaceMixin
    implements ShamirSecretPlgPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final ShamirSecretPlgPlatform initialPlatform = ShamirSecretPlgPlatform.instance;

  test('$MethodChannelShamirSecretPlg is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelShamirSecretPlg>());
  });

  test('getPlatformVersion', () async {
    ShamirSecretPlg shamirSecretPlgPlugin = ShamirSecretPlg();
    MockShamirSecretPlgPlatform fakePlatform = MockShamirSecretPlgPlatform();
    ShamirSecretPlgPlatform.instance = fakePlatform;

    expect(await shamirSecretPlgPlugin.getPlatformVersion(), '42');
  });
}
