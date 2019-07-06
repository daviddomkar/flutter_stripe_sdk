#import "FlutterStripeSDKPlugin.h"
#import <flutter_stripe_sdk/flutter_stripe_sdk-Swift.h>

@implementation FlutterStripeSDKPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterStripeSDKPlugin registerWithRegistrar:registrar];
}
@end
