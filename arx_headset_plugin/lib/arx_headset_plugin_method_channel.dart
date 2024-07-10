import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'arx_headset_plugin_platform_interface.dart';

/// An implementation of [ArxHeadsetPluginPlatform] that uses method channels.
class MethodChannelArxHeadsetPlugin extends ArxHeadsetPluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('arx_headset_plugin');

  @visibleForTesting
  final eventChannel = const EventChannel('arx_headset_plugin/callback');


  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  void initService() {
    methodChannel.invokeListMethod('initService');
  }

  @override
  Stream<String> getPermissionDeniedEvent() {
    return eventChannel
        .receiveBroadcastStream()
        .map((events) => events as String);
  }
}
