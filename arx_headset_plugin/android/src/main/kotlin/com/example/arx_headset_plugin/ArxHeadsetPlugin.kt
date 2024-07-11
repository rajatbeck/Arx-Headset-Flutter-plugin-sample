package com.example.arx_headset_plugin

import android.app.Activity
import android.content.Context
import android.graphics.Bitmap
import android.widget.Toast
import androidx.annotation.NonNull
import android.content.Intent



import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.embedding.android.FlutterFragmentActivity

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import com.arx.camera.ArxHeadsetApi
import com.arx.camera.foreground.ArxHeadsetHandler
import com.arx.camera.headsetbutton.ArxHeadsetButton
import com.arx.camera.headsetbutton.ImuData
import com.arx.camera.jni.UVCException
import com.arx.camera.state.UsbCameraPhotoCaptureException
import com.arx.camera.ui.ArxPermissionActivityResult
import com.arx.camera.util.Resolution
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.ComponentActivity
import com.example.arx_headset_plugin.MainActivity.Companion.ALL_PERMISSIONS_GRANTED
import com.example.arx_headset_plugin.MainActivity.Companion.BACK_PRESSED
import com.example.arx_headset_plugin.MainActivity.Companion.CLOSE_APP_REQUESTED
import com.example.arx_headset_plugin.MainActivity.Companion.USB_DISCONNECTED


/** ArxHeadsetPlugin */
class ArxHeadsetPlugin : FlutterPlugin, MethodCallHandler,
  ActivityAware, PluginRegistry.ActivityResultListener {

    companion object {
      const val REQUEST_CODE = 101
    }

  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var event : EventChannel
  private lateinit var toastEventChannel: EventChannel
  private var arxHeadsetHandler: ArxHeadsetHandler? = null
  private var onPermissionDeniedEvent: EventChannel.EventSink? = null
  private var toastEvent: EventChannel.EventSink? = null

  private val startResolution = Resolution._640x480
  private var activity : Activity? = null

  private val myActivityResultContract = com.arx.camera.ui.ArxPermissionActivityResultContract()

  private lateinit var myActivityResultLauncher: ActivityResultLauncher<Boolean>

  private val callbacks = object : ArxHeadsetCallbacks {
    override fun onPermissionDenied() {
      println("onPermissionDenied callbacks $onPermissionDeniedEvent")
      onPermissionDeniedEvent?.success("")
    }
  }

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "arx_headset_plugin")
    event = EventChannel(flutterPluginBinding.binaryMessenger, "arx_headset_plugin/callback")
    toastEventChannel = EventChannel(flutterPluginBinding.binaryMessenger,"arx_headset_plugin/toast")
    channel.setMethodCallHandler(this)
    event.setStreamHandler(object : EventChannel.StreamHandler {
      override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        onPermissionDeniedEvent = events
      }

      override fun onCancel(arguments: Any?) {
        onPermissionDeniedEvent = null
      }
    })
    toastEventChannel.setStreamHandler(object : EventChannel.StreamHandler {
      override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        toastEvent = events
      }

      override fun onCancel(arguments: Any?) {
        toastEvent = null
      }
    })
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    if (call.method == "getPlatformVersion") {
      result.success("Android ${android.os.Build.VERSION.RELEASE}")
    } else if (call.method == "initService") {
      startHeadsetService()
    } else if(call.method == "launchPermissionUi") {
      val intent = Intent(activity,MainActivity::class.java)
      activity?.startActivityForResult(intent, REQUEST_CODE)
    } else {
      result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
    event.setStreamHandler(null)
    toastEventChannel.setStreamHandler(null)
  }

  // ActivityAware interface methods
  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
    registerArxListener(binding.activity)
    binding.addActivityResultListener(this)
    println("onAttachedToActivity ${activity is ComponentActivity}")
  }

  override fun onDetachedFromActivityForConfigChanges() {
    activity = null
    arxHeadsetHandler = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    activity = binding.activity
    registerArxListener(binding.activity)
    binding.addActivityResultListener(this)
    println("onReattachedToActivityForConfigChanges ${activity is ComponentActivity}")
  }

  override fun onDetachedFromActivity() {
    activity = null
    arxHeadsetHandler = null
  }

  override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
    if (requestCode == REQUEST_CODE) {
      if (resultCode == Activity.RESULT_OK) {
        data ?: return false
        val result = data.getStringExtra(MainActivity.RESULT_TYPE)
        when (result) {
          ALL_PERMISSIONS_GRANTED -> {
            startHeadsetService()
          }
          BACK_PRESSED -> {
            toastEvent?.success("Back Pressed")
          }
          CLOSE_APP_REQUESTED -> {
            toastEvent?.success("Close app CTA clicked")
          }
          USB_DISCONNECTED -> {
            toastEvent?.success("Usb Disconnected")
          }
          else -> {}
        }
        return true
      } else {
        return false
      }
    }
    return false
  }

  private fun registerArxListener(activity: Context) {
    arxHeadsetHandler = ArxHeadsetHandler(
      activity,
      BuildConfig.DEBUG,
      object : ArxHeadsetApi {
        override fun onDeviceConnectionError(throwable: Throwable) {

        }

        override fun onDevicePhotoReceived(bitmap: Bitmap, currentFrameDesc: Resolution) {
        }

        override fun onStillPhotoReceived(bitmap: Bitmap, currentFrameDesc: Resolution) {

        }

        override fun onButtonClicked(arxButton: ArxHeadsetButton, isLongPress: Boolean) {
        }

        override fun onPermissionDenied() {
          callbacks.onPermissionDenied()
        }

        override fun onImuDataUpdate(imuData: ImuData) {
        }

        override fun onDisconnect() {
        }

        override fun onCameraResolutionUpdate(
          availableResolutions: List<Resolution>, selectedResolution: Resolution
        ) {

        }
      });
  }


  private fun startHeadsetService() {
    arxHeadsetHandler?.startHeadSetService(startResolution)
  }
}
