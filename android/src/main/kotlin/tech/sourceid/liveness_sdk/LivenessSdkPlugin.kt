package tech.sourceid.liveness_sdk

import android.app.Activity
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import tech.sourceid.sdk.liveness.data.LivenessUIConfig
import tech.sourceid.sdk.liveness.ui.LivenessSDK

/** LivenessSdkPlugin */
class LivenessSdkPlugin : FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware {

  private lateinit var channel: MethodChannel
  private var activity: Activity? = null
  private var pendingResult: MethodChannel.Result? = null

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "liveness_sdk")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    when (call.method) {
      "getPlatformVersion" -> result.success("Android ${android.os.Build.VERSION.RELEASE}")
      "startLiveness" -> handleStartLiveness(call, result)
      else -> result.notImplemented()
    }
  }

  private fun handleStartLiveness(call: MethodCall, result: MethodChannel.Result) {
    val sessionId = call.argument<String>("sessionId")
    val region = call.argument<String>("region")
    val hideBranding = call.argument<Boolean>("hideBranding") ?: false
    val customTitle = call.argument<String>("customTitle")
    val theme = call.argument<String>("theme") ?: "light"
    val primaryColorHex = call.argument<String>("primaryColorHex")

    if (sessionId.isNullOrEmpty() || region.isNullOrEmpty()) {
      result.error("INVALID_ARGUMENTS", "sessionId and region are required", null)
      return
    }

    val currentActivity = activity ?: run {
      result.error("NO_ACTIVITY", "No foreground activity available", null)
      return
    }

    if (pendingResult != null) {
      result.error("IN_PROGRESS", "Another liveness flow is already running", null)
      return
    }

    pendingResult = result

    val config = LivenessUIConfig(
      hideBranding = hideBranding,
      customTitle = customTitle,
      theme = theme,
      primaryColorHex = primaryColorHex
    )

    try {
      LivenessSDK.launch(
        context = currentActivity,
        sessionId = sessionId,
        region = region,
        config = config,
        onSuccess = { message ->
          pendingResult?.success(
            mapOf("status" to "success", "message" to message)
          )
          pendingResult = null
        },
        onError = { error ->
          val code = if (error.contains("cancel", ignoreCase = true)) "CANCELLED" else "LIVENESS_ERROR"
          pendingResult?.error(code, error, null)
          pendingResult = null
        }
      )
    } catch (e: Exception) {
      pendingResult = null
      result.error("LAUNCH_FAILED", e.localizedMessage, null)
    }
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivity() {
    activity = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivityForConfigChanges() {
    activity = null
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
