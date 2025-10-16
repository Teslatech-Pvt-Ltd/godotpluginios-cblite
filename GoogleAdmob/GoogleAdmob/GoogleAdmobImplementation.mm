//
//  GoogleAdmobImplementation.m
//  GoogleAdmob
//
//  Created by Samrat Singh on 19/09/2025.
//

#include "GoogleAdmobImplementation.h"
#include "GoogleAdmob.h"
#import "core/engine.h"
#import "core/object.h"
#import "AppTrackingTransparency/AppTrackingTransparency.h"
#import "AdSupport/AdSupport.h"
#import "GdObjcTypeBridge.h"
#import "InterstitialAd.h"
#include "Utils.h"

GoogleAdmob *GoogleAdmob::instance = NULL;

GoogleAdmob *GoogleAdmob::get_singleton() {
    return instance;
};

void GoogleAdmob::_bind_methods() {
    ClassDB::bind_method("check_for_consent", &GoogleAdmob::check_for_consent);
    ClassDB::bind_method("init", &GoogleAdmob::init);
    ClassDB::bind_method("set_ad_config", &GoogleAdmob::set_ad_config);
    ClassDB::bind_method("get_advertising_id", &GoogleAdmob::get_advertising_id);
    
    ClassDB::bind_method("load_ad", &GoogleAdmob::load_ad);
    ClassDB::bind_method("show_ad", &GoogleAdmob::show_ad);
    ClassDB::bind_method("destroy_ad", &GoogleAdmob::destroy_ad);
    ClassDB::bind_method("hide_ad", &GoogleAdmob::hide_ad);
    ClassDB::bind_method("is_ad_loaded", &GoogleAdmob::is_ad_loaded);
    ClassDB::bind_method("is_ad_visible", &GoogleAdmob::is_ad_visible);
    ClassDB::bind_method("get_ad_height", &GoogleAdmob::get_ad_height);
    
    ADD_SIGNAL(MethodInfo("consent_status_received",  PropertyInfo(Variant::BOOL, "isConsented")));
    ADD_SIGNAL(MethodInfo("initialized", PropertyInfo(Variant::BOOL, "isConsented")));
    ADD_SIGNAL(MethodInfo("ad_load_fail", PropertyInfo(Variant::STRING, "adName"),  PropertyInfo(Variant::STRING, "error")));
    ADD_SIGNAL(MethodInfo("ad_load_success", PropertyInfo(Variant::STRING, "adName")));
    ADD_SIGNAL(MethodInfo("ad_show_fail", PropertyInfo(Variant::STRING, "adName"), PropertyInfo(Variant::STRING, "error")));
    ADD_SIGNAL(MethodInfo("ad_show_success", PropertyInfo(Variant::STRING, "adName")));
    ADD_SIGNAL(MethodInfo("ad_impression", PropertyInfo(Variant::STRING, "adName")));
    ADD_SIGNAL(MethodInfo("ad_clicked", PropertyInfo(Variant::STRING, "adName")));
    ADD_SIGNAL(MethodInfo("ad_dismissed", PropertyInfo(Variant::STRING, "adName")));
    ADD_SIGNAL(MethodInfo("ad_ended", PropertyInfo(Variant::STRING, "adName")));
}


#pragma mark - Private Methods
void _get_gdpr_consent(BOOL testUMPForm, void(^completion)(BOOL canRequestAds)) {
    UMPRequestParameters *parameters = [[UMPRequestParameters alloc] init];
    
    if (testUMPForm) {
        [Utils logAdmob:@"Consent" message:@"Test UMP forms."];
        [Utils logAdmob:@"Consent" message:@"vendor ID: %@", [[[UIDevice currentDevice] identifierForVendor] UUIDString]];
        [Utils logAdmob:@"Consent" message:@"advertising ID: %@", [[ASIdentifierManager sharedManager] advertisingIdentifier]];
        
        UMPDebugSettings *debugSettings = [[UMPDebugSettings alloc] init];
        debugSettings.testDeviceIdentifiers = @[ [[[UIDevice currentDevice] identifierForVendor] UUIDString] ];
        debugSettings.geography = UMPDebugGeographyEEA;
        parameters.debugSettings = debugSettings;
    }
    
    [UMPConsentInformation.sharedInstance requestConsentInfoUpdateWithParameters:parameters completionHandler:^(NSError *_Nullable error) {
        if (error) {
            [Utils logAdmob:@"Consent" message:@"Consent Info Update Error: %@", error.localizedDescription];
            if (completion) {
                completion(false);
            }
            return;
        }

        UIViewController* rootController = [UIApplication sharedApplication].delegate.window.rootViewController;
        [UMPConsentForm loadAndPresentIfRequiredFromViewController:rootController completionHandler:^(NSError * _Nullable error) {
            if (completion) {
                completion(UMPConsentInformation.sharedInstance.canRequestAds);
            }
        }];
    }];
}

void _get_idfa(void(^completion)(BOOL isAttAuthorized)) {
    if (@available(iOS 14.0, *)) {
        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
            if (completion) {
                completion(status == ATTrackingManagerAuthorizationStatusAuthorized);
            }
        }];
    } else {
        if (completion) {
            completion(true);
        }
    }
}

#pragma mark - Godot Methods [Consent and Mobile Ads Initialization]
void GoogleAdmob::check_for_consent() {
    _get_idfa(^(BOOL isAttAuthorized) {
        [Utils logAdmob:@"IDFA" message:@"ATT Authorization Result: %s", isAttAuthorized ? "YES":"NO"];
        if (!isAttAuthorized) {
            GoogleAdmob::get_singleton()->emit_signal("consent_status_received", YES);
            return;
            // if Att is denied, do not show GDPR request as it will cause Apple review rejection. Just consider gdpr consented.
        }
        _get_gdpr_consent(testUMPMessageForm, ^(BOOL canRequestAds) {
            GoogleAdmob::get_singleton()->emit_signal("consent_status_received", canRequestAds);
        });
    });
}

void GoogleAdmob::init() {
    [[GADMobileAds sharedInstance] startWithCompletionHandler:^(GADInitializationStatus * _Nonnull status) {
        [Utils logAdmob:@"GADInit" message:@"Initialization Status: %d", status];
        NSDictionary<NSString *, GADAdapterStatus *>* states = [status adapterStatusesByClassName];
        GADAdapterStatus * adapterStatus = states[@"GADMobileAds"];
        GoogleAdmob::get_singleton()->emit_signal("initialized", adapterStatus.state == GADAdapterInitializationStateReady);
    }];
    [GADMobileAds.sharedInstance.audioVideoManager setAudioSessionIsApplicationManaged:YES];
}

void GoogleAdmob::set_ad_config(String ad_config) {
    NSString *jsonString = [GdObjcTypeBridge to_nsstring:ad_config];
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSDictionary *adConfigDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if (error == nil) {
        adConfig = adConfigDict;
    } else {
        [Utils logAdmob:@"GoogleAdmob" message:@"Error parsing ad_config."];
    }
}

#pragma mark - Godot Methods [Helper Methods]
String GoogleAdmob::get_advertising_id() {
    NSUUID *adID = [[ASIdentifierManager sharedManager] advertisingIdentifier];
    NSString *adIDString = [adID UUIDString];
    return [GdObjcTypeBridge from_nsstring:adIDString];
}

bool GoogleAdmob::is_ad_loaded(String ad_name) {
    NSString* adName = [GdObjcTypeBridge to_nsstring:ad_name];
    BaseAd* adObj = [Utils getAdObj:adName];
    if (adObj) {
        return [adObj isAdLoaded];
    }
    return false;
}

bool GoogleAdmob::is_ad_visible(String ad_name) {
    NSString* adName = [GdObjcTypeBridge to_nsstring:ad_name];
    BaseAd* adObj = [Utils getAdObj:adName];
    if (adObj) {
        return [adObj isAdVisible];
    }
    return false;
}

int GoogleAdmob::get_ad_height(String ad_name) {
    NSString* adName = [GdObjcTypeBridge to_nsstring:ad_name];
    BaseAd* adObj = [Utils getAdObj:adName];
    if (adObj) {
        return [adObj getHeightInPixels];
    }
    return -1;
}

#pragma mark - Godot Methods [Core Ad Functionality]
void GoogleAdmob::load_ad(String ad_name) {
    NSString* adName = [GdObjcTypeBridge to_nsstring:ad_name];
    BaseAd* adObj = [Utils getAdObj:adName];
    if (adObj) [adObj loadAd:adName];
}

void GoogleAdmob::show_ad(String ad_name) {
    NSString* adName = [GdObjcTypeBridge to_nsstring:ad_name];
    BaseAd* adObj = [Utils getAdObj:adName];
    if (adObj) [adObj showAd];
}

void GoogleAdmob::destroy_ad(String ad_name) {
    NSString* adName = [GdObjcTypeBridge to_nsstring:ad_name];
    BaseAd* adObj = [Utils getAdObj:adName];
    if (adObj) [adObj destroyAd];
}

void GoogleAdmob::hide_ad(String ad_name) {
    NSString* adName = [GdObjcTypeBridge to_nsstring:ad_name];
    BaseAd* adObj = [Utils getAdObj:adName];
    if (adObj) [adObj hideAd];
}

#pragma mark - Godot Methods [Constructor/Destructor]
GoogleAdmob::GoogleAdmob(){
    instance = this;
    testUMPMessageForm = false;
    
    videoInterstitialAdObj = [[InterstitialAd alloc] init];
    nonVideoInterstitialAdObj = [[InterstitialAd alloc] init];
    bottomBannerObj = [[BannerAd alloc] init];
    openAdObj = [[AppOpenAd alloc] init];
}

GoogleAdmob::~GoogleAdmob(){
    videoInterstitialAdObj = nil;
    nonVideoInterstitialAdObj = nil;
    bottomBannerObj = nil;
    openAdObj = nil;
    
    if (instance == this) {
        instance = NULL;
    }
}

