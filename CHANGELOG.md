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
