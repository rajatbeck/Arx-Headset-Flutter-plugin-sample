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

  @visibleForTesting
  final toastChannel = const EventChannel('arx_headset_plugin/toast');

  @visibleForTesting
  final resolutionChannel = const EventChannel('arx_headset_plugin/resolution');


 @visibleForTesting
  final bitmapChannel = const EventChannel('arx_headset_plugin/bitmap');

   @visibleForTesting
  final imuChannel = const EventChannel('arx_headset_plugin/imu');

   @visibleForTesting
  final disconnectedChannel = const EventChannel('arx_headset_plugin/disconnected');




  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  void startArxHeadSet() {
    methodChannel.invokeListMethod('startArxHeadSet');
  }

  @override
  Stream<String> getPermissionDeniedEvent() {
    return eventChannel
        .receiveBroadcastStream()
        .map((events) => events as String);
  }

  @override
  void launchPermissionUi() {
    methodChannel.invokeListMethod('launchPermissionUi');
  }

  @override
  Stream<String> getUpdateViaMessage() {
    return toastChannel.receiveBroadcastStream()
        .map((events) => events as String);
  }

  @override
  Stream<String> getListOfResolutions() {
    return resolutionChannel
        .receiveBroadcastStream()
        .map((events) => events as String);
  }

  @override
  Stream<dynamic> getBitmapStream() {
    return bitmapChannel
        .receiveBroadcastStream()
        .map((events) => events as dynamic);
  }

  @override
  Stream<String> getImuDataStream() {
    return imuChannel
        .receiveBroadcastStream()
        .map((events) => events as String);
  }

  @override
  Stream<String> disconnectedStream() {
    return disconnectedChannel
        .receiveBroadcastStream()
        .map((event) => event as String);
  }
}
