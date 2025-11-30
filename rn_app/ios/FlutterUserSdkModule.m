#import <React/RCTBridgeModule.h>
#import <React/RCTUtils.h>
#import <Flutter/Flutter.h>

#import "AppDelegate.h"

@interface FlutterUserSdk : NSObject <RCTBridgeModule>
@end

@implementation FlutterUserSdk

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(openUserProfile:(nonnull NSNumber *)userId
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  dispatch_async(dispatch_get_main_queue(), ^{
    AppDelegate *delegate = (AppDelegate *)UIApplication.sharedApplication.delegate;
    FlutterEngine *engine = delegate.flutterEngine;
    if (engine == nil) {
      reject(@"no_engine", @"Flutter engine not initialized", nil);
      return;
    }

    FlutterMethodChannel *channel =
        [FlutterMethodChannel methodChannelWithName:@"flutter_user_sdk/user"
                                    binaryMessenger:engine.binaryMessenger];
    [channel invokeMethod:@"showUserProfile" arguments:@{@"userId" : userId}];

    FlutterViewController *controller =
        [[FlutterViewController alloc] initWithEngine:engine nibName:nil bundle:nil];

    UIViewController *presentedController = RCTPresentedViewController();
    if (presentedController == nil) {
      reject(@"no_controller", @"Unable to find a presenting controller", nil);
      return;
    }

    [presentedController presentViewController:controller animated:YES completion:^{
      resolve(@(YES));
    }];
  });
}

@end
