#import "AppAuthenticationKitPlugin.h"
#if __has_include(<app_authentication_kit/app_authentication_kit-Swift.h>)
#import <app_authentication_kit/app_authentication_kit-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "app_authentication_kit-Swift.h"
#endif

@implementation AppAuthenticationKitPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAppAuthenticationKitPlugin registerWithRegistrar:registrar];
}
@end
