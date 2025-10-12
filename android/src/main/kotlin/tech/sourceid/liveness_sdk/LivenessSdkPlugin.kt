package tech.sourceid.liveness_sdk

import android.app.Activity
import android.content.Intent
import android.util.Log
import androidx.annotation.NonNull
//import com.amplifyframework.auth.cognito.AWSCognitoAuthPlugin
//import com.amplifyframework.core.Amplify
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import tech.sourceid.sdk.liveness.data.LivenessUIConfig
import tech.sourceid.sdk.liveness.ui.LivenessLaunchParams
import tech.sourceid.sdk.liveness.ui.LivenessResult
import tech.sourceid.sdk.liveness.ui.LivenessSDK

/** LivenessSdkPlugin */
class LivenessSdkPlugin : FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware {

  private lateinit var channel: MethodChannel
  private var activity: Activity? = null
  private var binding: ActivityPluginBinding? = null
  private var pendingResult: MethodChannel.Result? = null

  private val REQUEST_CODE_LIVENESS = 9001

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "liveness_sdk")
    channel.setMethodCallHandler(this)

/*    try {
      Amplify.addPlugin(AWSCognitoAuthPlugin())
      Amplify.configure(flutterPluginBinding.applicationContext)
      Log.i("LivenessSdkPlugin", "✅ Amplify initialized successfully")
    } catch (e: Exception) {
      Log.e("LivenessSdkPlugin", "⚠️ Amplify initialization failed", e)
    }*/
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

    val config = LivenessUIConfig(
      hideBranding = hideBranding,
      customTitle = customTitle,
      theme = theme,
      primaryColorHex = primaryColorHex
    )

    startLivenessFlow(sessionId, region, config, result)
  }

  private fun startLivenessFlow(
    sessionId: String,
    region: String,
    config: LivenessUIConfig,
    result: MethodChannel.Result
  ) {
    val currentActivity = activity ?: run {
      result.error("NO_ACTIVITY", "No foreground activity available", null)
      return
    }

    if (pendingResult != null) {
      result.error("IN_PROGRESS", "Another Liveness flow is already running", null)
      return
    }

    pendingResult = result

    try {
      LivenessSDK.launch(
        context = currentActivity,
        sessionId = sessionId,
        region = region,
        config = config,
        onSuccess = { message ->
          Log.i("LivenessSdkPlugin", "✅ Success: $message")
          pendingResult?.success(
            mapOf("status" to "success", "message" to message)
          )
          pendingResult = null
        },
        onError = { error ->
          Log.e("LivenessSdkPlugin", "❌ Error: $error")
          pendingResult?.error("LIVENESS_ERROR", error, null)
          pendingResult = null
        }
      )
    } catch (e: Exception) {
      Log.e("LivenessSdkPlugin", "❌ Exception launching LivenessSDK", e)
      result.error("LAUNCH_FAILED", e.localizedMessage, null)
      pendingResult = null
    }
  }

/*
  override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
    if (requestCode != REQUEST_CODE_LIVENESS) return false

    val result = pendingResult ?: return false

    try {
      val livenessResult = LivenessSDK.parseResult(resultCode, data)
      when (livenessResult) {
        is LivenessResult.Success -> {
          Log.i("LivenessSdkPlugin", "✅ Success: ${livenessResult.message}")
          result.success(
            mapOf(
              "status" to "success",
              "message" to livenessResult.message
            )
          )
        }
        is LivenessResult.Error -> {
          Log.e("LivenessSdkPlugin", "❌ Error: ${livenessResult.message}")
          result.error("LIVENESS_ERROR", livenessResult.message, null)
        }
      }
    } catch (e: Exception) {
      Log.e("LivenessSdkPlugin", "❌ Failed to parse Liveness result", e)
      result.error("RESULT_PARSE_FAILED", e.localizedMessage, null)
    }

    pendingResult = null
    return true
  }
*/

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
    this.binding = binding
//    binding.addActivityResultListener(this)
  }

  override fun onDetachedFromActivity() {
//    binding?.removeActivityResultListener(this)
    binding = null
    activity = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    activity = binding.activity
    this.binding = binding
//    binding.addActivityResultListener(this)
  }

  override fun onDetachedFromActivityForConfigChanges() {
//    binding?.removeActivityResultListener(this)
    binding = null
    activity = null
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
