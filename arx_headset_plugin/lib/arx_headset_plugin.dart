
import 'arx_headset_plugin_platform_interface.dart';

class ArxHeadsetPlugin {
  Future<String?> getPlatformVersion() {
    return ArxHeadsetPluginPlatform.instance.getPlatformVersion();
  }
  void startArxHeadSet() {
    ArxHeadsetPluginPlatform.instance.startArxHeadSet();
  }

  Stream<String> getPermissionDeniedEvent() {
    return ArxHeadsetPluginPlatform.instance.getPermissionDeniedEvent();
  }

  void launchPermissionUi() {
    ArxHeadsetPluginPlatform.instance.launchPermissionUi();
  }

  Stream<String> getUpdateViaMessage() {
    return ArxHeadsetPluginPlatform.instance.getUpdateViaMessage();
  }

  Stream<String> getListOfResolutions() {
    return ArxHeadsetPluginPlatform.instance.getListOfResolutions();
  }

  Stream<dynamic> getBitmapStream() {
    return ArxHeadsetPluginPlatform.instance.getBitmapStream();
  }

  Stream<String> getImuDataStream() {
    return ArxHeadsetPluginPlatform.instance.getImuDataStream();
  }

  Stream<String> disconnectedStream() {
    return ArxHeadsetPluginPlatform.instance.disconnectedStream();
  }
}
