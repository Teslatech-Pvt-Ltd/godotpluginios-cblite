//
//  AppOpenAd.h
//  GoogleAdmob
//
//  Created by Samrat Singh on 09/10/2025.
//

#include "Foundation/Foundation.h"
#import "BaseAd.h"
#import "GoogleMobileAds/GoogleMobileAds.h"

@interface AppOpenAd : BaseAd <GADFullScreenContentDelegate>

@property GADAppOpenAd* openAd;
@property UIViewController* root_controller;
@property BOOL shouldPresentAd;

@end
