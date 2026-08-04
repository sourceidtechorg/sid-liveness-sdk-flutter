## 0.2.0

Structured errors, pre-flight session check, custom start page.

* Consumes native SDKs Android `liveness-expo` `v1.6.2` and iOS `ios-single-liveness-expo` `1.6.0`.
* New optional `apiConfig` (`LivenessApiConfig`: `baseUrl`, `apiKey`, `bearerToken`) on `startLiveness`: the native SDK verifies the session status against the SourceID gateway and only opens the camera when it is `CREATED`.
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
