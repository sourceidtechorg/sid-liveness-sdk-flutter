import Flutter
import UIKit
import SwiftUI
import LivenessCheck

public class LivenessSdkPlugin: NSObject, FlutterPlugin {

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "liveness_sdk", binaryMessenger: registrar.messenger())
    let instance = LivenessSdkPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    case "startLiveness":
      handleStartLiveness(call: call, result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func handleStartLiveness(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let sessionId = args["sessionId"] as? String, !sessionId.isEmpty else {
      result(FlutterError(
        code: "INVALID_ARGUMENTS",
        message: "sessionId is required",
        details: nil
      ))
      return
    }
    let region = (args["region"] as? String).flatMap { $0.isEmpty ? nil : $0 } ?? "us-east-1"

    let config = LivenessUIConfig(
      hideBranding: args["hideBranding"] as? Bool ?? false,
      customTitle: args["customTitle"] as? String,
      theme: args["theme"] as? String ?? "light",
      primaryColorHex: args["primaryColorHex"] as? String
    )

    var apiConfig: LivenessApiConfig?
    if let apiConfigMap = args["apiConfig"] as? [String: Any] {
      guard let baseUrl = apiConfigMap["baseUrl"] as? String, !baseUrl.isEmpty,
            let apiKey = apiConfigMap["apiKey"] as? String, !apiKey.isEmpty,
            let bearerToken = apiConfigMap["bearerToken"] as? String, !bearerToken.isEmpty else {
        result(FlutterError(
          code: "INVALID_ARGUMENTS",
          message: "apiConfig requires baseUrl, apiKey, and bearerToken",
          details: nil
        ))
        return
      }
      apiConfig = LivenessApiConfig(baseUrl: baseUrl, apiKey: apiKey, bearerToken: bearerToken)
    }

    // Validate the session before presenting ANY UI: a faulty session is
    // reported to Dart without the camera screen ever appearing.
    if let apiConfig {
      Task { @MainActor in
        if let error = await LivenessSDK.checkSession(sessionId: sessionId, apiConfig: apiConfig) {
          result(FlutterError(
            code: error.code,
            message: error.userMessage,
            details: error.debugMessage
          ))
          return
        }
        // Already validated — skip the SDK-internal re-check.
        self.presentLiveness(sessionId: sessionId, region: region, config: config, result: result)
      }
    } else {
      presentLiveness(sessionId: sessionId, region: region, config: config, result: result)
    }
  }

  private func presentLiveness(
    sessionId: String,
    region: String,
    config: LivenessUIConfig,
    result: @escaping FlutterResult
  ) {
    DispatchQueue.main.async {
      guard let rootViewController = Self.topViewController() else {
        result(FlutterError(
          code: "NO_VIEW_CONTROLLER",
          message: "Could not find a view controller to present from",
          details: nil
        ))
        return
      }

      var hostRef: UIViewController?
      var completed = false

      let livenessView = LivenessSDK.start(
        sessionId: sessionId,
        region: region,
        config: config
      ) { livenessResult in
        DispatchQueue.main.async {
          // The detector can surface multiple events; only the first outcome counts.
          guard !completed else { return }
          completed = true
          hostRef?.dismiss(animated: true)

          switch livenessResult {
          case .success:
            result([
              "status": "success",
              "message": "Liveness check completed successfully"
            ])
          case .failure(let error):
            // code/userMessage/debugMessage map onto PlatformException's
            // code/message/details on the Dart side.
            result(FlutterError(
              code: error.code,
              message: error.userMessage,
              details: error.debugMessage
            ))
          }
        }
      }

      let hostingController = UIHostingController(rootView: livenessView)
      hostingController.modalPresentationStyle = .fullScreen
      hostRef = hostingController
      rootViewController.present(hostingController, animated: true)
    }
  }

  private static func topViewController() -> UIViewController? {
    let keyWindow = UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap { $0.windows }
      .first { $0.isKeyWindow }

    guard var top = keyWindow?.rootViewController else { return nil }
    while let presented = top.presentedViewController {
      top = presented
    }
    return top
  }
}
