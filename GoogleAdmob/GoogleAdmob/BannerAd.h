//
//  BannerAd.h
//  GoogleAdmob
//
//  Created by Samrat Singh on 08/10/2025.
//

#include "Foundation/Foundation.h"
#import "BaseAd.h"
#import "GoogleMobileAds/GoogleMobileAds.h"


@interface BannerAd : BaseAd <GADBannerViewDelegate>

@property GADBannerView* bannerView;
@property UIViewController* rootController;

@end
