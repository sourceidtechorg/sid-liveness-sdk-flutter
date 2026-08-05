package tech.sourceid.liveness_sdk

import android.app.Activity
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import tech.sourceid.sdk.liveness.data.LivenessApiConfig
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
    val region = call.argument<String>("region") ?: "us-east-1"
    val hideBranding = call.argument<Boolean>("hideBranding") ?: false
    val customTitle = call.argument<String>("customTitle")
    val theme = call.argument<String>("theme") ?: "light"
    val primaryColorHex = call.argument<String>("primaryColorHex")
    val apiConfigMap = call.argument<Map<String, Any?>>("apiConfig")

    if (sessionId.isNullOrEmpty()) {
      result.error("INVALID_ARGUMENTS", "sessionId is required", null)
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

    val apiConfig = apiConfigMap?.let {
      val baseUrl = it["baseUrl"] as? String
      val apiKey = it["apiKey"] as? String
      val bearerToken = it["bearerToken"] as? String
      if (baseUrl.isNullOrBlank() || apiKey.isNullOrBlank() || bearerToken.isNullOrBlank()) {
        pendingResult = null
        result.error(
          "INVALID_ARGUMENTS",
          "apiConfig requires baseUrl, apiKey, and bearerToken",
          null
        )
        return
      }
      LivenessApiConfig(baseUrl = baseUrl, apiKey = apiKey, bearerToken = bearerToken)
    }

    try {
      LivenessSDK.launch(
        context = currentActivity,
        sessionId = sessionId,
        region = region,
        config = config,
        apiConfig = apiConfig,
        onSuccess = { message, sessionResult ->
          // sessionResult (scored gateway result) is present when apiConfig
          // was provided; the SDK fetched it after the capture completed.
          pendingResult?.success(
            mapOf(
              "status" to "success",
              "message" to message,
              "sessionStatus" to sessionResult?.status,
              "confidence" to sessionResult?.confidence,
              "referenceImageUrl" to sessionResult?.referenceImageUrl
            )
          )
          pendingResult = null
        },
        onError = { error ->
          // code/userMessage/debugMessage map onto PlatformException's
          // code/message/details on the Dart side.
          pendingResult?.error(error.code, error.userMessage, error.debugMessage)
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
