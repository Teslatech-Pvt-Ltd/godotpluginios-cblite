//
//  AdCallbackHandler.mm
//  GoogleAdmob
//
//  Created by Samrat Singh on 25/09/2025.
//

#include "AdCallbackHandler.h"
#import "GoogleAdmobImplementation.h"
#import "GdObjcTypeBridge.h"

@implementation AdCallbackHandler

+ (void)adLoadFailure:(NSString *)adName error:(NSError *)error {
    GoogleAdmob::get_singleton()->emit_signal("ad_load_fail",
                                              [GdObjcTypeBridge from_nsstring:adName],
                                              [GdObjcTypeBridge from_nsstring:error.localizedDescription]);
}

+ (void)adLoadSuccess:(NSString *)adName {
    GoogleAdmob::get_singleton()->emit_signal("ad_load_success", [GdObjcTypeBridge from_nsstring:adName]);
}

+ (void)adShowFailure:(NSString *)adName error:(NSError * _Nullable)error {
    GoogleAdmob::get_singleton()->emit_signal("ad_show_fail",
                                              [GdObjcTypeBridge from_nsstring:adName],
                                              [GdObjcTypeBridge from_nsstring:error ? error.localizedDescription : @""]);
}

+ (void)adShowSuccess:(NSString *)adName {
    GoogleAdmob::get_singleton()->emit_signal("ad_show_success", [GdObjcTypeBridge from_nsstring:adName]);
}

+ (void)adImpressionReceived:(NSString *)adName {
    GoogleAdmob::get_singleton()->emit_signal("ad_impression", [GdObjcTypeBridge from_nsstring:adName]);
}

+ (void)adClicked:(NSString *)adName {
    GoogleAdmob::get_singleton()->emit_signal("ad_clicked", [GdObjcTypeBridge from_nsstring:adName]);
}

+ (void)adDismiss:(NSString *)adName {
    GoogleAdmob::get_singleton()->emit_signal("ad_dismissed", [GdObjcTypeBridge from_nsstring:adName]);
}

+ (void)adEnded:(NSString *)adName {
    GoogleAdmob::get_singleton()->emit_signal("ad_ended", [GdObjcTypeBridge from_nsstring:adName]);
}

@end
