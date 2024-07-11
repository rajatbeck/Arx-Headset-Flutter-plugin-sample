import 'package:flutter_test/flutter_test.dart';
import 'package:arx_headset_plugin/arx_headset_plugin.dart';
import 'package:arx_headset_plugin/arx_headset_plugin_platform_interface.dart';
import 'package:arx_headset_plugin/arx_headset_plugin_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/*
class MockArxHeadsetPluginPlatform
    with MockPlatformInterfaceMixin
    implements ArxHeadsetPluginPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final ArxHeadsetPluginPlatform initialPlatform = ArxHeadsetPluginPlatform.instance;

  test('$MethodChannelArxHeadsetPlugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelArxHeadsetPlugin>());
  });

  test('getPlatformVersion', () async {
    ArxHeadsetPlugin arxHeadsetPlugin = ArxHeadsetPlugin();
    MockArxHeadsetPluginPlatform fakePlatform = MockArxHeadsetPluginPlatform();
    ArxHeadsetPluginPlatform.instance = fakePlatform;

    expect(await arxHeadsetPlugin.getPlatformVersion(), '42');
  });
}
*/
