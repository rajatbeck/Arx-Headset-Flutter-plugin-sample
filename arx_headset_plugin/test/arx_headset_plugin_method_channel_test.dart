import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arx_headset_plugin/arx_headset_plugin_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelArxHeadsetPlugin platform = MethodChannelArxHeadsetPlugin();
  const MethodChannel channel = MethodChannel('arx_headset_plugin');

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
