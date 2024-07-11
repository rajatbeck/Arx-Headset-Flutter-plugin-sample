
import 'arx_headset_plugin_platform_interface.dart';

class ArxHeadsetPlugin {
  Future<String?> getPlatformVersion() {
    return ArxHeadsetPluginPlatform.instance.getPlatformVersion();
  }
  void initService() {
    ArxHeadsetPluginPlatform.instance.initService();
  }

  Stream<String> getPermissionDeniedEvent() {
    return ArxHeadsetPluginPlatform.instance.getPermissionDeniedEvent();
  }

  void launchPermissionUi() {
    ArxHeadsetPluginPlatform.instance.launchPermissionUi();
  }
}
