//
//  AppOpenAd.mm
//  GoogleAdmob
//
//  Created by Samrat Singh on 09/10/2025.
//

#include "AppOpenAd.h"
#import "Utils.h"

@implementation AppOpenAd
- (instancetype)init {
    self = [super init];
    if (self) {
        self.isLoaded = NO;
        self.isVisible = NO;
        self.shouldPresentAd = NO;
        self.root_controller = [UIApplication sharedApplication].delegate.window.rootViewController;
    }
    return self;
}

#pragma mark - Core Ad Functionality
- (void)loadAd:(NSString *)adName {
    self.adName = adName;
    self.adUnitId = [Utils getAdUnitId:adName];
    [Utils logAdmob:adName message:@"Loading Ad with unitID: %@", self.adUnitId];
    
    GADRequest *request = [[GADRequest alloc] init];
    [GADAppOpenAd loadWithAdUnitID:self.adUnitId
                           request:request
                 completionHandler:^(GADAppOpenAd * _Nullable appOpenAd, NSError * _Nullable error) {
        if (error) {
            [Utils logAdmob:self.adName message:@"Load Failure. %@", error.localizedDescription];
            [AdCallbackHandler adLoadFailure:self.adName error:error];
        } else {
            [Utils logAdmob:self.adName message:@"Load Success."];
            
            self.openAd = appOpenAd;
            self.openAd.fullScreenContentDelegate = self;
            self.isLoaded = YES;
            [AdCallbackHandler adLoadSuccess:self.adName];
            
            [self addEventListeners];
        }
    }];
}

- (void)showAd {
    if (self.openAd && self.isLoaded && self.shouldPresentAd) {
        [self.openAd presentFromRootViewController:self.root_controller];
    } else {
        [AdCallbackHandler adShowFailure:self.adName error:nil];
    }
}

- (void)destroyAd {
    if (self.openAd) {
        self.openAd.fullScreenContentDelegate = nil;
        self.openAd = nil;
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

- (int)getHeight {return -1;}
- (int)getHeightInPixels {return -1;}
- (int)getWidth {return -1;}
- (int)getWidthInPixels {return -1;}

- (void)addEventListeners { // listeners for openad show call
    [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(_set_ad_ready_to_show)
                                             name:UIApplicationWillEnterForegroundNotification
                                            object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(showAd)
                                             name:UIApplicationDidBecomeActiveNotification
                                            object:nil];
    // using only appDidBecomeActiveNotification causes show_ad to trigger after system popups as well(Eg. notification/att permission)
    // using only appWillEnterForegroundNotification causes show_ad to trigger too soon such that banner ad cannot be hidden on time
}

-(void)removeEventListeners {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                 name:UIApplicationDidBecomeActiveNotification
                                                 object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillEnterForegroundNotification
                                                 object:nil];
}

-(void)_set_ad_ready_to_show {
    self.shouldPresentAd = YES;
}


#pragma mark - Ad Callbacks
- (void)ad:(id<GADFullScreenPresentingAd>)ad didFailToPresentFullScreenContentWithError:(NSError *)error {
    [AdCallbackHandler adShowFailure:self.adName error:error];
    [Utils logAdmob:self.adName message:@"Show Ad Failure. %@", error.localizedDescription];
}

- (void)adWillPresentFullScreenContent:(id<GADFullScreenPresentingAd>)ad {
    [AdCallbackHandler adShowSuccess:self.adName];
    self.isVisible = YES;
    [Utils logAdmob:self.adName message:@"Show Ad Success."];
}

- (void)adDidRecordImpression:(id<GADFullScreenPresentingAd>)ad {
    [AdCallbackHandler adImpressionReceived:self.adName];
    [Utils logAdmob:self.adName message:@"Ad Recorded Impression."];
}

- (void)adWillDismissFullScreenContent:(id<GADFullScreenPresentingAd>)ad {
    [AdCallbackHandler adDismiss:self.adName];
    [AdCallbackHandler adEnded:self.adName];
    self.isVisible = NO;
    self.isLoaded = NO;
    
    self.shouldPresentAd = NO;
    [self removeEventListeners];
    
    [Utils logAdmob:self.adName message:@"Ad Dismissed."];
}

- (void)adDidRecordClick:(id<GADFullScreenPresentingAd>)ad {
    [AdCallbackHandler adClicked:self.adName];
    [Utils logAdmob:self.adName message:@"Ad Clicked."];
}

- (void)adDidDismissFullScreenContent:(id<GADFullScreenPresentingAd>)ad {}

@end
