//
//  InterstitialAd.h
//  GoogleAdmob
//
//  Created by Samrat Singh on 23/09/2025.
//

#include "BaseAd.h"
#include "Foundation/Foundation.h"
#import "GoogleMobileAds/GoogleMobileAds.h"


@interface InterstitialAd : BaseAd <GADFullScreenContentDelegate>

@property GADInterstitialAd* interstitialAd;
@property UIViewController* rootController;

@end
