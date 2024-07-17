package com.example.arx_headset_plugin


import android.app.Activity
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.os.Looper
import androidx.activity.ComponentActivity
import com.arx.camera.ArxHeadsetApi
import com.arx.camera.foreground.ArxHeadsetHandler
import com.arx.camera.headsetbutton.ArxHeadsetButton
import com.arx.camera.headsetbutton.ImuData
import com.arx.camera.util.Resolution
import com.example.arx_headset_plugin.MainActivity.Companion.ALL_PERMISSIONS_GRANTED
import com.example.arx_headset_plugin.MainActivity.Companion.BACK_PRESSED
import com.example.arx_headset_plugin.MainActivity.Companion.CLOSE_APP_REQUESTED
import com.example.arx_headset_plugin.MainActivity.Companion.USB_DISCONNECTED
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.cancel
import kotlinx.coroutines.channels.BufferOverflow
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.launch
import java.io.ByteArrayOutputStream


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
  private lateinit var resolutionEventChannel: EventChannel
  private lateinit var bitmapEventChannel: EventChannel
  private lateinit var imuEventChannel: EventChannel
  private lateinit var disconnectedEventChannel: EventChannel
  private var arxHeadsetHandler: ArxHeadsetHandler? = null
  private var onPermissionDeniedEvent: EventChannel.EventSink? = null
  private var toastEvent: EventChannel.EventSink? = null
  private var resolutionListEvent: EventChannel.EventSink? = null
  private var bitmapEvent: EventChannel.EventSink? = null
  private var imuEvent: EventChannel.EventSink? = null
  private var disconnectedEvent: EventChannel.EventSink? = null

  private val mainScope = CoroutineScope(Dispatchers.Main)
  private val ioScope = CoroutineScope(Dispatchers.IO)
  private val imuDataFlow = MutableSharedFlow<String>(replay = 1)
  private val byteArrayFlow =
    MutableSharedFlow<ByteArray>(
      replay = 1,
      onBufferOverflow = BufferOverflow.DROP_OLDEST)


  private val startResolution = Resolution._640x480
  private var activity : Activity? = null

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
    resolutionEventChannel = EventChannel(flutterPluginBinding.binaryMessenger,"arx_headset_plugin/resolution")
    bitmapEventChannel = EventChannel(flutterPluginBinding.binaryMessenger,"arx_headset_plugin/bitmap")
    imuEventChannel = EventChannel(flutterPluginBinding.binaryMessenger,"arx_headset_plugin/imu")
    disconnectedEventChannel = EventChannel(flutterPluginBinding.binaryMessenger,"arx_headset_plugin/disconnected")
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
    resolutionEventChannel.setStreamHandler(object: EventChannel.StreamHandler {
      override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        resolutionListEvent = events
      }

      override fun onCancel(arguments: Any?) {
        resolutionListEvent = null
      }
    })
    bitmapEventChannel.setStreamHandler(object: EventChannel.StreamHandler {
      override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        bitmapEvent = events
      }

      override fun onCancel(arguments: Any?) {
        bitmapEvent = null
      }
    })
    imuEventChannel.setStreamHandler(object: EventChannel.StreamHandler {
      override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        imuEvent = events
        startListening()
      }

      override fun onCancel(arguments: Any?) {
        imuEvent = null
      }
    })
    disconnectedEventChannel.setStreamHandler(object: EventChannel.StreamHandler {
      override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        disconnectedEvent = events
      }

      override fun onCancel(arguments: Any?) {
        disconnectedEvent = null
      }
    })

  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
        "getPlatformVersion" -> {
          result.success("Android ${android.os.Build.VERSION.RELEASE}")
        }
        "startArxHeadSet" -> {
          startHeadsetService()
        }
        "launchPermissionUi" -> {
          val intent = Intent(activity,MainActivity::class.java)
          activity?.startActivityForResult(intent, REQUEST_CODE)
        }
        "stopArxHeadset" -> {
          arxHeadsetHandler?.stopHeadsetService()
        }
        else -> {
          result.notImplemented()
        }
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
    event.setStreamHandler(null)
    toastEventChannel.setStreamHandler(null)
    resolutionEventChannel.setStreamHandler(null)
    bitmapEventChannel.setStreamHandler(null)
    imuEventChannel.setStreamHandler(null)
    disconnectedEventChannel.setStreamHandler(null)
    mainScope.cancel()
    ioScope.cancel()
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
          ioScope.launch {
            val stream = ByteArrayOutputStream()
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
            val byteArray = stream.toByteArray()
            byteArrayFlow.emit(byteArray)
            bitmap.recycle()
          }
        }

        override fun onStillPhotoReceived(bitmap: Bitmap, currentFrameDesc: Resolution) {

        }

        override fun onButtonClicked(arxButton: ArxHeadsetButton, isLongPress: Boolean) {
          val message = when {
            (arxButton == ArxHeadsetButton.VolumeUp && isLongPress) -> "Volume up button long pressed"
            (arxButton == ArxHeadsetButton.VolumeUp) -> "Volume up button short pressed"
            (arxButton == ArxHeadsetButton.VolumeDown && isLongPress) -> "Volume down button long pressed"
            (arxButton == ArxHeadsetButton.VolumeDown) -> "Volume down button short pressed"
            (arxButton == ArxHeadsetButton.Square && isLongPress) -> "Square button long pressed"
            (arxButton == ArxHeadsetButton.Square) -> "Square button short pressed"
            (arxButton == ArxHeadsetButton.Circle && isLongPress) -> "Circle button long pressed"
            (arxButton == ArxHeadsetButton.Circle) -> "Circle button short pressed"
            (arxButton == ArxHeadsetButton.Triangle && isLongPress) -> "Triangle button long pressed"
            (arxButton == ArxHeadsetButton.Triangle) -> "Triangle button short pressed"
            else -> ""
          }
          toastEvent?.success(message)
        }

        override fun onPermissionDenied() {
          callbacks.onPermissionDenied()
        }

        override fun onImuDataUpdate(imuData: ImuData) {
          ioScope.launch {
             imuDataFlow.emit(imuData.toString())
          }

        }

        override fun onDisconnect() {
          disconnectedEvent?.success("")
        }

        override fun onCameraResolutionUpdate(
          availableResolutions: List<Resolution>, selectedResolution: Resolution
        ) {
          resolutionListEvent?.success("") //todo send resolution list and selected resolution
        }
      });
  }

  private fun startListening() {
    mainScope.launch {
      imuDataFlow.collect { data ->
        imuEvent?.success(data)
      }
    }
    mainScope.launch {
      byteArrayFlow
        .collectLatest { data ->
        bitmapEvent?.success(data)
      }
    }
  }


  private fun startHeadsetService() {
    arxHeadsetHandler?.startHeadSetService(startResolution)
  }
}
