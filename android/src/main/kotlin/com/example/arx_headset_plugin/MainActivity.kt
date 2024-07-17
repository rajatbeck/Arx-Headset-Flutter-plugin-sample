package com.example.arx_headset_plugin

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import androidx.activity.result.ActivityResultLauncher
import com.arx.camera.ui.ArxPermissionActivityResult


class MainActivity: FlutterFragmentActivity() {

    companion object {
        const val ALL_PERMISSIONS_GRANTED = "ALL_PERMISSIONS_GRANTED"
        const val BACK_PRESSED = "BACK_PRESSED"
        const val CLOSE_APP_REQUESTED = "CLOSE_APP_REQUESTED"
        const val USB_DISCONNECTED = "USB_DISCONNECTED"
        const val RESULT_TYPE = "result_type"
    }


    private val myActivityResultContract = com.arx.camera.ui.ArxPermissionActivityResultContract()


    private val myActivityResultLauncher = registerForActivityResult(myActivityResultContract) {
        when (it) {
            ArxPermissionActivityResult.AllPermissionsGranted -> {
                println("permission granted!!!")
                val intent = Intent()
                intent.putExtra(RESULT_TYPE,ALL_PERMISSIONS_GRANTED)
                setResult(Activity.RESULT_OK,intent)
                finish()
            }

            ArxPermissionActivityResult.BackPressed -> {
                println("BackPressed")
                val intent = Intent()
                intent.putExtra(RESULT_TYPE,BACK_PRESSED)
                setResult(Activity.RESULT_OK,intent)
                finish()
            }

            ArxPermissionActivityResult.CloseAppRequested -> {
                println("CloseAppRequested")
                val intent = Intent()
                intent.putExtra(RESULT_TYPE,CLOSE_APP_REQUESTED)
                setResult(Activity.RESULT_OK,intent)
                finish()
            }

            ArxPermissionActivityResult.UsbDisconnected -> {
                println("usb disconnected")
                val intent = Intent()
                intent.putExtra(RESULT_TYPE,USB_DISCONNECTED)
                setResult(Activity.RESULT_OK,intent)
                finish()
            }

            else -> {}
        }
    }

    override protected fun onCreate(savedInstanceState:Bundle?) {
        super.onCreate(savedInstanceState)
        println("On create called")
        myActivityResultLauncher.launch(true)
    }


}