import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shamir_secret_plg/shamir_secret_plg_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelShamirSecretPlg platform = MethodChannelShamirSecretPlg();
  const MethodChannel channel = MethodChannel('shamir_secret_plg');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
