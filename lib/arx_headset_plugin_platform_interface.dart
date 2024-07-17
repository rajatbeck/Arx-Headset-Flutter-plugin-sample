import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'arx_headset_plugin_method_channel.dart';

abstract class ArxHeadsetPluginPlatform extends PlatformInterface {
  /// Constructs a ArxHeadsetPluginPlatform.
  ArxHeadsetPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static ArxHeadsetPluginPlatform _instance = MethodChannelArxHeadsetPlugin();

  /// The default instance of [ArxHeadsetPluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelArxHeadsetPlugin].
  static ArxHeadsetPluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [ArxHeadsetPluginPlatform] when
  /// they register themselves.
  static set instance(ArxHeadsetPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  void startArxHeadSet() {
    throw UnimplementedError('startArxHeadSet() has not been implemented.');
  }

  Stream<String> getPermissionDeniedEvent() {
    throw UnimplementedError('getPermissionDeniedEvent() has not been implemented.');
  }

  void launchPermissionUi() {
    throw UnimplementedError('launchPermission() has not been implemented');
  }

  void stopArxHeadset() {
    throw UnimplementedError('stopArxHeadset() has not been implemented');
  }

  Stream<String> getUpdateViaMessage() {
    throw UnimplementedError('toastEvent() has not been implemented.');
  }

  Stream<String> getListOfResolutions() {
    throw UnimplementedError('getListOfResolutions() has not been implemented.');
  }

  Stream<dynamic> getBitmapStream() {
    throw UnimplementedError('getBitmapStream() has not been implemented');
  }

  Stream<String> getImuDataStream() {
    throw UnimplementedError('getImuDataStream() has not been implemented');
  }

  Stream<String> disconnectedStream() {
    throw UnimplementedError('disconnectedStream() has not been implemented');
  }
}
