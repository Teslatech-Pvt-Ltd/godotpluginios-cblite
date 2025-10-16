//
//  GoogleAdmobImplementation.h
//  GoogleAdmob
//
//  Created by Samrat Singh on 19/09/2025.
//

#include "Foundation/Foundation.h"
#include "core/object.h"
#include "core/class_db.h"
#import "BaseAd.h"
#import "GoogleMobileAds/GoogleMobileAds.h"
#import "UserMessagingPlatform/UserMessagingPlatform.h"
#import "AdCallbackHandler.h"
#import "Utils.h"
#import "InterstitialAd.h"
#import "BannerAd.h"
#import "AppOpenAd.h"

class GoogleAdmob: public Object {
    GDCLASS(GoogleAdmob, Object);
    static GoogleAdmob *instance;
    static void _bind_methods();
    
    BOOL testUMPMessageForm;
    
public:
    
    NSDictionary *adConfig;
    static GoogleAdmob* get_singleton();
    
    InterstitialAd* videoInterstitialAdObj;
    InterstitialAd* nonVideoInterstitialAdObj;
    BannerAd* bottomBannerObj;
    AppOpenAd* openAdObj;
    
    void check_for_consent();
    void init();
    void set_ad_config(String ad_config);
    String get_advertising_id();
    
    void load_ad(String ad_name);
    void show_ad(String ad_name);
    void destroy_ad(String ad_name);
    void hide_ad(String ad_name);
    bool is_ad_loaded(String ad_name);
    bool is_ad_visible(String ad_name);
    int get_ad_height(String ad_name);
    
    GoogleAdmob();
    ~GoogleAdmob();
};
