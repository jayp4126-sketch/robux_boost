//
//  Generated file. Do not edit.
//

// clang-format off

#import "GeneratedPluginRegistrant.h"

#if __has_include(<app_tracking_transparency/AppTrackingTransparencyPlugin.h>)
#import <app_tracking_transparency/AppTrackingTransparencyPlugin.h>
#else
@import app_tracking_transparency;
#endif

#if __has_include(<firebase_core/FLTFirebaseCorePlugin.h>)
#import <firebase_core/FLTFirebaseCorePlugin.h>
#else
@import firebase_core;
#endif

#if __has_include(<firebase_remote_config/FirebaseRemoteConfigPlugin.h>)
#import <firebase_remote_config/FirebaseRemoteConfigPlugin.h>
#else
@import firebase_remote_config;
#endif

#if __has_include(<google_mobile_ads/FLTGoogleMobileAdsPlugin.h>)
#import <google_mobile_ads/FLTGoogleMobileAdsPlugin.h>
#else
@import google_mobile_ads;
#endif

#if __has_include(<onesignal_flutter/OneSignalPlugin.h>)
#import <onesignal_flutter/OneSignalPlugin.h>
#else
@import onesignal_flutter;
#endif

#if __has_include(<share_plus/FPPSharePlusPlugin.h>)
#import <share_plus/FPPSharePlusPlugin.h>
#else
@import share_plus;
#endif

#if __has_include(<shared_preferences_foundation/SharedPreferencesPlugin.h>)
#import <shared_preferences_foundation/SharedPreferencesPlugin.h>
#else
@import shared_preferences_foundation;
#endif

#if __has_include(<singular_flutter_sdk/SingularSDK.h>)
#import <singular_flutter_sdk/SingularSDK.h>
#else
@import singular_flutter_sdk;
#endif

#if __has_include(<url_launcher_ios/URLLauncherPlugin.h>)
#import <url_launcher_ios/URLLauncherPlugin.h>
#else
@import url_launcher_ios;
#endif

#if __has_include(<webview_flutter_wkwebview/WebViewFlutterPlugin.h>)
#import <webview_flutter_wkwebview/WebViewFlutterPlugin.h>
#else
@import webview_flutter_wkwebview;
#endif

@implementation GeneratedPluginRegistrant

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
  [AppTrackingTransparencyPlugin registerWithRegistrar:[registry registrarForPlugin:@"AppTrackingTransparencyPlugin"]];
  [FLTFirebaseCorePlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTFirebaseCorePlugin"]];
  [FirebaseRemoteConfigPlugin registerWithRegistrar:[registry registrarForPlugin:@"FirebaseRemoteConfigPlugin"]];
  [FLTGoogleMobileAdsPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTGoogleMobileAdsPlugin"]];
  [OneSignalPlugin registerWithRegistrar:[registry registrarForPlugin:@"OneSignalPlugin"]];
  [FPPSharePlusPlugin registerWithRegistrar:[registry registrarForPlugin:@"FPPSharePlusPlugin"]];
  [SharedPreferencesPlugin registerWithRegistrar:[registry registrarForPlugin:@"SharedPreferencesPlugin"]];
  [SingularSDK registerWithRegistrar:[registry registrarForPlugin:@"SingularSDK"]];
  [URLLauncherPlugin registerWithRegistrar:[registry registrarForPlugin:@"URLLauncherPlugin"]];
  [WebViewFlutterPlugin registerWithRegistrar:[registry registrarForPlugin:@"WebViewFlutterPlugin"]];
}

@end
