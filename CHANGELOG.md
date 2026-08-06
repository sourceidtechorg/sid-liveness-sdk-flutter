## 0.4.0

Environment-based gateway selection.

* `startLiveness` takes `environment` (`LivenessEnvironment.production` / `.sandbox` / `.uat` / `.development`) instead of `apiConfig` — the SDK derives the gateway base URL internally. `LivenessApiConfig` is removed.
* No bearer token is needed anymore; `apiKey` (the `x-api-key` header) is a plain optional parameter, kept only until the gateway stops requiring it for `liveness-result`.

## 0.3.0

Scored results in the success callback.

* Consumes native SDKs Android `sid-liveness-sdk-android` `v1.8.1` and iOS `sid-liveness-sdk-ios` `1.8.1` (official `sourceidtechorg` coordinates).
* When `apiConfig` is provided, the SDK fetches the scored result from the gateway's `liveness-result` endpoint right after the capture completes; `LivenessResult` now carries `sessionStatus` (e.g. `SUCCEEDED`), `confidence` (0–100), and `referenceImageUrl` (short-lived signed URL). A fetch failure never masks a successful capture — the fields are simply null.
* iOS: the pre-flight session check now runs **before** any UI is presented (native `LivenessSDK.checkSession`), matching Android — a faulty session produces only the error callback with no screen shown.

## 0.2.0

Structured errors, pre-flight session check, custom start page.

* Consumes native SDKs Android `liveness-expo` `v1.6.2` and iOS `ios-single-liveness-expo` `1.6.0`.
* New optional `apiConfig` (`LivenessApiConfig`: `baseUrl`, `apiKey`, `bearerToken`) on `startLiveness`: the session status is verified against the SourceID gateway **before any native UI is presented** — the flow only launches when the status is `CREATED`; otherwise the host app just receives the error.
* `LivenessException` now carries `message` (friendly, user-facing) and `debugMessage` (full technical detail); native SDKs also log every failure themselves (Android Logcat tag `LivenessSDK`, iOS os_log subsystem `tech.sourceid.LivenessCheck`).
* New stable error codes shared across platforms: `CANCELLED`, `CAMERA_PERMISSION_DENIED`, `INVALID_ARGUMENTS`, `SESSION_NOT_USABLE`, `STATUS_CHECK_FAILED`, `CONFIG_FAILED`, `DETECTOR_FAILED` (plus plugin-level `NO_ACTIVITY`/`NO_VIEW_CONTROLLER`/`IN_PROGRESS`). `LIVENESS_ERROR` is replaced by `DETECTOR_FAILED`.
* `region` is now optional and defaults to `us-east-1`.
* Both platforms show a SourceID instruction page (matching the web liveness flow) instead of AWS's stock start view.

## 0.1.0

First functional release.

* Android and iOS liveness flow bridged to Dart via `LivenessSdk.startLiveness`.
* Android: consumes the published native SDK `com.github.EQua-Dev:liveness-expo:v1.2.0` (JitPack).
* iOS: consumes the published native SDK `ios-single-liveness-expo` `1.4.0` via Swift Package Manager (requires Flutter's SPM support — `flutter config --enable-swift-package-manager`; CocoaPods cannot express the SPM-only AWS FaceLiveness dependency).
* Typed errors via `LivenessException` with stable codes (`CANCELLED`, `INVALID_ARGUMENTS`, `IN_PROGRESS`, `LIVENESS_ERROR`, ...).
* iOS: the liveness modal is dismissed automatically when the flow completes; failures reject instead of resolving.
* Guaranteed single callback per launch, including user cancellation and permission denial.
* UI customization via `LivenessUIConfig` (theme, title, primary color, branding).

## 0.0.1

* Initial scaffold.
