import Flutter
import UIKit
import Stripe

public class SwiftFlutterStripePlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_stripe", binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterStripePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
      case "init":
        _init(publishableKey: (call.arguments as! Dictionary<String, AnyObject>)["publishableKey"] as! String)
        result(nil)
        break
      default:
        result(FlutterMethodNotImplemented);
        break
    }
    
    result("iOS " + UIDevice.current.systemVersion)
  }
    
  private func _init(publishableKey: String) {
    STPPaymentConfiguration.shared().publishableKey = publishableKey
  }
}
