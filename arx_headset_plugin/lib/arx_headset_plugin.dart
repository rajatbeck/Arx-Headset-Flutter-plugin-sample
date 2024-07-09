
import 'arx_headset_plugin_platform_interface.dart';

class ArxHeadsetPlugin {
  Future<String?> getPlatformVersion() {
    return ArxHeadsetPluginPlatform.instance.getPlatformVersion();
  }
}
