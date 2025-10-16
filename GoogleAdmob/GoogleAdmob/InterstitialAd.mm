//
//  InterstitialAd.mm
//  GoogleAdmob
//
//  Created by Samrat Singh on 23/09/2025.
//

#include "InterstitialAd.h"
#import "GoogleAdmobImplementation.h"
#import "AdCallbackHandler.h"

@implementation InterstitialAd
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.isLoaded = false;
        self.isVisible = false;
        self.rootController = [UIApplication sharedApplication].delegate.window.rootViewController;
    }
    return self;
}


#pragma mark - Core Ad Functionality
- (void)loadAd:(NSString *)adName{
    self.adName = adName;
    self.adUnitId = [Utils getAdUnitId:adName];
    GADRequest* request = [[GADRequest alloc] init];
    [Utils logAdmob:adName message:@"Loading Ad with unitID: %@", self.adUnitId];
    
    [GADInterstitialAd loadWithAdUnitID:self.adUnitId request:request completionHandler:^(GADInterstitialAd * _Nullable ad, NSError * _Nullable error) {
        if (error) {
            [Utils logAdmob:adName message:@"Load Failure. %@", error.localizedDescription];
            [AdCallbackHandler adLoadFailure:adName error:error];
        } else {
            [Utils logAdmob:adName message:@"Load Success."];
            
            self.interstitialAd = ad;
            self.interstitialAd.fullScreenContentDelegate = self;
            self.isLoaded = true;
            [AdCallbackHandler adLoadSuccess:adName];
        }
    }];
}

- (void)showAd {
    if (self.interstitialAd) {
        [self.interstitialAd presentFromRootViewController:self.rootController];
    } else {
        [Utils logAdmob:self.adName message:@"Ad Show Failure"];
        [AdCallbackHandler adEnded:self.adName];
        [AdCallbackHandler adShowFailure:self.adName error:nil];
    }
}

- (void)destroyAd {
    if(self.interstitialAd != nil) {
        self.interstitialAd.fullScreenContentDelegate = nil;
        self.interstitialAd = nil;
    }
}

- (void)hideAd {}


#pragma mark - Helper Methods
- (bool)isAdLoaded {
    return self.isLoaded;
}

- (bool)isAdVisible {
    return self.isVisible;
}

- (int)getWidth {return -1;}
- (int)getHeight {return -1;}
- (int)getWidthInPixels{return -1;}
- (int)getHeightInPixels {return -1;}


#pragma mark - Ad Callbacks
- (void)adDidRecordImpression:(id<GADFullScreenPresentingAd>)ad {
    [AdCallbackHandler adImpressionReceived:self.adName];
    [Utils logAdmob:self.adName message:@"Ad Recorded Impression."];
}

- (void)adWillPresentFullScreenContent:(id<GADFullScreenPresentingAd>)ad {
    self.isVisible = true;
    [AdCallbackHandler adShowSuccess:self.adName];
    [Utils logAdmob:self.adName message:@"Show Ad Success."];
}

- (void)ad:(id<GADFullScreenPresentingAd>)ad didFailToPresentFullScreenContentWithError:(NSError *)error {
    [AdCallbackHandler adEnded:self.adName];
    [AdCallbackHandler adShowFailure:self.adName error:error];
    [Utils logAdmob:self.adName message:@"Show Ad Failure. %@", error.localizedDescription];
}

- (void)adWillDismissFullScreenContent:(id<GADFullScreenPresentingAd>)ad {
    self.isLoaded = false;
    self.isVisible = false;
    [AdCallbackHandler adEnded:self.adName];
    [AdCallbackHandler adDismiss:self.adName];
    [Utils logAdmob:self.adName message:@"Ad Dismissed."];
}

- (void)adDidRecordClick:(id<GADFullScreenPresentingAd>)ad {
    [AdCallbackHandler adClicked:self.adName];
    [Utils logAdmob:self.adName message:@"Ad Clicked."];
}

- (void)adDidDismissFullScreenContent:(id<GADFullScreenPresentingAd>)ad {}

@end
