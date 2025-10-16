//
//  Utils.mm
//  GoogleAdmob
//
//  Created by Samrat Singh on 25/09/2025.
//

#include "Utils.h"
#import "GoogleAdmobImplementation.h"

@implementation Utils

+(NSString*)getAdUnitId:(NSString *)adName {
    NSDictionary *adConfig = GoogleAdmob::get_singleton()->adConfig;
    if (adConfig && [adConfig isKindOfClass:[NSDictionary class]]) {
        return adConfig[adName][@"id"] ?: @"";
    }
    return @"";
}

+(NSString*)getAdmobType:(NSString *)adName {
    NSDictionary *adConfig = GoogleAdmob::get_singleton()->adConfig;
    if (adConfig && [adConfig isKindOfClass:[NSDictionary class]]) {
        return adConfig[adName][@"admob_type"] ?: @"";
    }
    return @"";
}

+(void)logAdmob:(NSString *)adName message:(NSString *)message, ... {
    va_list args;
    va_start(args, message);
    NSString *formattedMessage = [[NSString alloc] initWithFormat:message arguments:args];
    va_end(args);
    NSString *logString = [NSString stringWithFormat:@"[Admob] [%@] %@", adName, formattedMessage];
    NSLog(@"%@", logString);
}

+(BaseAd*)getAdObj:(NSString *)adName {
    NSString* admobType = [self getAdmobType:adName];
    
    if ([admobType isEqual: @"Interstitial"]) {
        if ([adName isEqual:@"VideoAd"]) {
            return GoogleAdmob::get_singleton()->videoInterstitialAdObj;
        } else if ([adName isEqual:@"NonVideoAd"]) {
            return GoogleAdmob::get_singleton()->nonVideoInterstitialAdObj;
        }
    } else if ([admobType isEqual:@"Banner"]) {
        if ([adName isEqual:@"BottomAdaptive"]) {
            return GoogleAdmob::get_singleton()->bottomBannerObj;
        }
    } else if ([admobType isEqual:@"Rewarded"]) {
        
    } else if ([admobType isEqual:@"AppOpen"]) {
        if ([adName isEqual:@"AppOpen"]) {
            return GoogleAdmob::get_singleton()->openAdObj;
        }
    } else if ([admobType isEqual:@"Native"]) {
        
    }
    return [[BaseAd alloc] init];
}

@end
