package com.softozin.sz_core

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import android.app.Application
import android.widget.Toast
import android.graphics.Color
import android.graphics.drawable.GradientDrawable
import android.view.Gravity
import android.widget.TextView
import android.os.Build

/** SzCorePlugin */
class SzCorePlugin :
    FlutterPlugin,
    MethodCallHandler {
    // The MethodChannel that will the communication between Flutter and native Android
    //
    // This local reference serves to register the plugin with the Flutter Engine and unregister it
    // when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var application: Application

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        application = flutterPluginBinding.applicationContext as Application
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "sz_core")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(
        call: MethodCall,
        result: Result
    ) {
        if (call.method == "showToast") {
            val message = call.argument<String>("message") ?: ""
            val bgColor = (call.argument<Number>("backgroundColor")
                ?: Color.BLACK).toInt()

            val textColor = (call.argument<Number>("textColor")
                ?: Color.WHITE).toInt()

            val fontSize = (call.argument<Number>("fontSize")
                ?: 12).toFloat()

            val duration = (call.argument<Number>("duration")
                ?: Toast.LENGTH_SHORT).toInt()

            val textView = TextView(application).apply {
                text = message
                setTextColor(textColor)
                textSize = fontSize
                setPadding(40, 24, 40, 24)
                gravity = Gravity.CENTER

                background = GradientDrawable().apply {
                    cornerRadius = 16f
                    setColor(bgColor)
                }
            }

            val toast = Toast(application)
            toast.duration = duration
            toast.view = textView
            toast.setGravity(Gravity.BOTTOM or Gravity.CENTER_HORIZONTAL, 0, 120)
            toast.show()

            result.success(null)
        } else if (call.method == "getScreenSize") {

            val metrics = application.resources.displayMetrics

            val widthDp = metrics.widthPixels / metrics.density
            val heightDp = metrics.heightPixels / metrics.density

            result.success(
                mapOf(
                    "width" to widthDp,
                    "height" to heightDp
                )
            )

        }else if (call.method == "getDeviceInfo") {
            val prefs = application.getSharedPreferences("sz_core", Context.MODE_PRIVATE)

            val androidId = Settings.Secure.getString(
                application.contentResolver,
                Settings.Secure.ANDROID_ID
            ).takeUnless { it.isNullOrBlank() }
                ?: prefs.getString("device_id", null)
                ?: UUID.randomUUID().toString().also {
                    prefs.edit().putString("device_id", it).apply()
                }

            val packageInfo = application.packageManager.getPackageInfo(
                application.packageName,
                0
            )

            val appName = application.applicationInfo
                .loadLabel(application.packageManager)
                .toString()

            val appVersion = packageInfo.versionName ?: "0.0.0"

            val appBuild = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                packageInfo.longVersionCode.toString()
            } else {
                @Suppress("DEPRECATION")
                packageInfo.versionCode.toString()
            }

            val info = mapOf(
                "platform" to "Android",
                "app_name" to appName,
                "app_version" to appVersion,
                "app_build" to appBuild,

                "manufacturer" to Build.MANUFACTURER,
                "brand" to Build.BRAND,
                "model" to Build.MODEL,
                "device" to Build.DEVICE,
                "product" to Build.PRODUCT,

                "android_version" to Build.VERSION.RELEASE,
                "sdk" to Build.VERSION.SDK_INT.toString(),

                "abis" to Build.SUPPORTED_ABIS.joinToString(","),
                "identifier" to androidId
            )

            result.success(info)
        } else {
            result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
