#import "FlutterStripePlugin.h"
#import <flutter_stripe/flutter_stripe-Swift.h>

@implementation FlutterStripePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterStripePlugin registerWithRegistrar:registrar];
}
@end
