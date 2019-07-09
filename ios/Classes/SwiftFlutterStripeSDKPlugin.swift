import Flutter
import UIKit
import Stripe

public class SwiftFlutterStripeSDKPlugin: NSObject, FlutterPlugin {
  private let ephemeralKeyProvider: EphemeralKeyProvider;
  private let methodChannel: FlutterMethodChannel;
  
  private var customerSession: STPCustomerContext?;
  
  init(methodChannel: FlutterMethodChannel) {
    self.methodChannel = methodChannel
    self.ephemeralKeyProvider = EphemeralKeyProvider(methodChannel: methodChannel)
  }
  
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_stripe_sdk", binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterStripeSDKPlugin(methodChannel: channel)
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
      case "init":
        _init(publishableKey: (call.arguments as! Dictionary<String, AnyObject>)["publishableKey"] as! String)
        result(nil)
        break
    case "initCustomerSession":
      _initCustomerSession();
      result(nil)
      break
    case "onKeyUpdate":
      ephemeralKeyProvider.keyUpdateListener?((call.arguments as! Dictionary<String, AnyObject>)["stripeResponseJson"] as? [String: AnyObject], nil)
      
      result(nil)
      break
    case "onKeyUpdateFailure":
      ephemeralKeyProvider.keyUpdateListener?(nil, NSError(domain: "flutter_stripe_sdk", code: (call.arguments as! Dictionary<String, AnyObject>)["responseCode"] as! Int, userInfo: ["message": (call.arguments as! Dictionary<String, AnyObject>)["message"] as! String]))

      result(nil)
      break
    case "retrieveCurrentCustomer":
      _retrieveCurrentCustomer(result: result)
      break;
    case "updateCurrentCustomer":
      _retrieveCurrentCustomer(result: result)
      break;
    case "getPaymentMethods":
      _retrieveCurrentCustomer(result: result)
      break;
    case "attachPaymentMethod":
      _retrieveCurrentCustomer(result: result)
      break;
    case "detachPaymentMethod":
      _retrieveCurrentCustomer(result: result)
      break;
    case "endCustomerSession":
      _endCustomerSession()
      result(nil)
      break
    default:
      result(FlutterMethodNotImplemented)
      break
    }
  }
    
  private func _init(publishableKey: String) {
    STPPaymentConfiguration.shared().publishableKey = publishableKey
  }
  
  private func _initCustomerSession() {
    customerSession = STPCustomerContext(keyProvider: ephemeralKeyProvider)
  }
  
  private func _retrieveCurrentCustomer(result: @escaping FlutterResult) {
    customerSession?.retrieveCustomer({ (customer: STPCustomer?, error: Error?) in
      if (customer != nil) {
        result(customer?.allResponseFields)
      }
      
      if (error != nil) {
        result(FlutterError(code: "0", message: "Failed to retrieve current customer. Possible connection issues.", details: nil))
      }
    })
  }
  
  private func _updateCurrenCustomer(result: @escaping FlutterResult) {
    customerSession?.updateCustomer(withShippingAddress: STPAddress(), completion: { (error: Error?) in
      if (error != nil) {
        result(FlutterError(code: "0", message: "Failed to update current customer. Possible connection issues.", details: nil))
      } else {
        result(nil)
      }
    })
  }
  
  private func _getPaymentMethods(type: STPPaymentMethodType, result: @escaping FlutterResult) {
    customerSession?.listPaymentMethodsForCustomer(completion: { (paymenMethods: [STPPaymentMethod]?, error: Error?) in
      if (paymenMethods != nil) {
        result(paymenMethods?.map({ (paymentMethod: STPPaymentMethod) -> [AnyHashable : Any] in
          return paymentMethod.allResponseFields
        }))
      }
      
      if (error != nil) {
        result(FlutterError(code: "0", message: "Failed to get payment methods. Possible connection issues.", details: nil))
      }
    })
  }
  
  private func _attachPaymentMethod(id: String, result: @escaping FlutterResult) {
    let method = STPPaymentMethod()
    method.stripeId = id;
    
    customerSession?.attachPaymentMethod(toCustomer: method, completion: { (error: Error?) in
      if (error != nil) {
        result(FlutterError(code: "0", message: "Failed to attach payment method. Possible connection issues.", details: nil))
      } else {
        result(nil)
      }
    })
  }
  
  private func _detachPaymentMethod(id: String, result: @escaping FlutterResult) {
    let method = STPPaymentMethod()
    method.stripeId = id;
    
    customerSession?.detachPaymentMethod(fromCustomer: method, completion: { (error: Error?) in
      if (error != nil) {
        result(FlutterError(code: "0", message: "Failed to detach payment method. Possible connection issues.", details: nil))
      } else {
        result(nil)
      }
    })
  }
  
  private func _endCustomerSession() {
    customerSession?.clearCache()
    customerSession = nil;
  }
}

private class EphemeralKeyProvider: NSObject, STPCustomerEphemeralKeyProvider {
  private let methodChannel: FlutterMethodChannel;

  public var keyUpdateListener: STPJSONResponseCompletionBlock?;
  
  init (methodChannel: FlutterMethodChannel) {
    self.methodChannel = methodChannel;
  }
  
  func createCustomerKey(withAPIVersion apiVersion: String, completion: @escaping STPJSONResponseCompletionBlock) {
    keyUpdateListener = completion;
    methodChannel.invokeMethod("createEphemeralKey", arguments: ["apiVersion": apiVersion])
  }
}
