import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'arx_headset_plugin_platform_interface.dart';

/// An implementation of [ArxHeadsetPluginPlatform] that uses method channels.
class MethodChannelArxHeadsetPlugin extends ArxHeadsetPluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('arx_headset_plugin');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
