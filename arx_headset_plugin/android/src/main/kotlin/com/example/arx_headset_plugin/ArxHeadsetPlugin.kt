package com.example.arx_headset_plugin

import android.app.Activity
import android.content.Context
import android.graphics.Bitmap
import android.widget.Toast
import androidx.annotation.NonNull
import androidx.appcompat.app.AppCompatActivity



import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import com.arx.camera.ArxHeadsetApi
import com.arx.camera.foreground.ArxHeadsetHandler
import com.arx.camera.headsetbutton.ArxHeadsetButton
import com.arx.camera.headsetbutton.ImuData
import com.arx.camera.jni.UVCException
import com.arx.camera.state.UsbCameraPhotoCaptureException
import com.arx.camera.ui.ArxPermissionActivityResult
import com.arx.camera.util.Resolution
import androidx.activity.result.ActivityResultLauncher



/** ArxHeadsetPlugin */
class ArxHeadsetPlugin: FlutterPlugin, MethodCallHandler, EventChannel.StreamHandler,ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var event : EventChannel
  private lateinit var arxHeadsetHandler: ArxHeadsetHandler
  private var onPermissionDeniedEvent: EventChannel.EventSink? = null

  private val startResolution = Resolution._640x480
  private var activity : Activity? = null

  private val myActivityResultContract = com.arx.camera.ui.ArxPermissionActivityResultContract()


  private lateinit var myActivityResultLauncher: ActivityResultLauncher<Boolean>

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "arx_headset_plugin")
    event = EventChannel(flutterPluginBinding.binaryMessenger, "arx_headset_plugin/callback")
    channel.setMethodCallHandler(this)
    event.setStreamHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    if (call.method == "getPlatformVersion") {
      result.success("Android ${android.os.Build.VERSION.RELEASE}")
    } else if (call.method == "initService") {
      println("initService called ${activity}")
      startHeadsetService(activity!!, object : ArxHeadsetCallbacks {
        override fun onPermissionDenied() {
          println("onPermissionDenied callbacks $onPermissionDeniedEvent")
          onPermissionDeniedEvent?.success("")
        }

      })
    } else {
      result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
    event.setStreamHandler(null)
  }

  override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
    println("onListen called = $arguments")
    onPermissionDeniedEvent = events
  }

  override fun onCancel(arguments: Any?) {
    onPermissionDeniedEvent = null
  }

  // ActivityAware interface methods
  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    println("onAttachedToActivity")
    activity = binding.activity
  }

  override fun onDetachedFromActivityForConfigChanges() {
    activity = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    println("onReattachedToActivityForConfigChanges")
    activity = binding.activity
  }

  override fun onDetachedFromActivity() {
    activity = null
  }


  private fun startHeadsetService(activity: Context, callbacks: ArxHeadsetCallbacks) {
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
    arxHeadsetHandler.startHeadSetService(startResolution)
  }
}
