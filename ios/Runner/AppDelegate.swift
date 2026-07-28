import Flutter
import UIKit
import PushKit
import flutter_callkit_incoming

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate, PKPushRegistryDelegate {
  private let voipRegistry = PKPushRegistry(queue: .main)

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    voipRegistry.delegate = self
    voipRegistry.desiredPushTypes = [.voIP]
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }

  // MARK: - PKPushRegistryDelegate (VoIP push for incoming calls)
  //
  // Regular FCM pushes are not delivered reliably enough to wake a backgrounded/terminated
  // app for an incoming call. VoIP push via PushKit gets high-priority delivery even from a
  // killed state, but in exchange Apple requires every VoIP push to result in a
  // CXProvider.reportNewIncomingCall call before this delegate method returns.

  func pushRegistry(
    _ registry: PKPushRegistry,
    didUpdate pushCredentials: PKPushCredentials,
    for type: PKPushType
  ) {
    guard type == .voIP else { return }
    let tokenHex = pushCredentials.token.map { String(format: "%02x", $0) }.joined()
    // Also emits DID_UPDATE_DEVICE_PUSH_TOKEN_VOIP to the Dart onEvent stream.
    SwiftFlutterCallkitIncomingPlugin.sharedInstance?.setDevicePushTokenVoIP(tokenHex)
  }

  func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
    guard type == .voIP else { return }
    SwiftFlutterCallkitIncomingPlugin.sharedInstance?.setDevicePushTokenVoIP("")
  }

  func pushRegistry(
    _ registry: PKPushRegistry,
    didReceiveIncomingPushWith payload: PKPushPayload,
    for type: PKPushType,
    completion: @escaping () -> Void
  ) {
    guard type == .voIP else {
      completion()
      return
    }
    let callData = flutter_callkit_incoming.Data(args: payload.dictionaryPayload as NSDictionary)
    SwiftFlutterCallkitIncomingPlugin.sharedInstance?.showCallkitIncoming(
      callData, fromPushKit: true, completion: completion)
  }
}
