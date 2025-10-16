//
//  BannerAd.mm
//  GoogleAdmob
//
//  Created by Samrat Singh on 08/10/2025.
//

#include "BannerAd.h"
#import "Utils.h"

@implementation BannerAd

- (instancetype)init {
    self = [super init];
    if (self) {
        self.isLoaded = NO;
        self.isVisible = NO;
        self.rootController = [UIApplication sharedApplication].delegate.window.rootViewController;
    }
    return self;
}

#pragma mark - Core Ad Functionality
- (void)loadAd:(NSString *)adName {
    self.adName = adName;
    self.adUnitId = [Utils getAdUnitId:adName];
    [Utils logAdmob:adName message:@"Loading Ad with unitID: %@", self.adUnitId];
    
    GADAdSize bannerSize;
    if ([adName  isEqual: @"BottomBanner"]) {
        bannerSize = GADAdSizeBanner;
    }
    
    self.bannerView = [[GADBannerView alloc] initWithAdSize:GADInlineAdaptiveBannerAdSizeWithWidthAndMaxHeight([UIScreen mainScreen].bounds.size.width, 50.0)];
    self.bannerView.adUnitID = self.adUnitId;
    self.bannerView.delegate = self;
    self.bannerView.rootViewController = self.rootController;
    [self.bannerView setHidden:YES];
    
    GADRequest *request = [GADRequest request];
    [self.bannerView loadRequest:request];
}

- (void)showAd {
    [Utils logAdmob:self.adName message:@"Showing Ad."];
    if (self.bannerView) {
        [self.bannerView setHidden:NO];
        self.isVisible = YES;
        [Utils logAdmob:self.adName message:@"Show Ad Success."];
    } else {
        [Utils logAdmob:self.adName message:@"Show Ad Failure. %@", @"Banner View not ready."];
    }
}

- (void)destroyAd {
    [Utils logAdmob:self.adName message:@"Destroying Ad."];
    if (self.bannerView) {
        [self hideAd];
        [self.bannerView removeFromSuperview];
        self.bannerView = nil;
        
        self.isLoaded = NO;
        [Utils logAdmob:self.adName message:@"Ad Dismissed."];
    }
}

- (void)hideAd {
    [Utils logAdmob:self.adName message:@"Hiding Ad."];
    if (self.bannerView) {
        [self.bannerView setHidden:YES];
        self.isVisible = NO;
    }
}

#pragma mark - Helper Methods
- (bool)isAdLoaded {
    return self.isLoaded;
}

- (bool)isAdVisible {
    return self.isVisible;
}

- (void)setBannerConstraints {
    self.bannerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.rootController.view addSubview:self.bannerView];
    [self.rootController.view addConstraint:
     [NSLayoutConstraint constraintWithItem:self.bannerView
                                 attribute:NSLayoutAttributeCenterX
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.rootController.view
                                 attribute:NSLayoutAttributeCenterX
                                multiplier:1
                                   constant:0]];
    if ([self.adName  isEqual: @"BottomAdaptive"]) {
        [self.rootController.view addConstraint:
         [NSLayoutConstraint constraintWithItem:self.bannerView
                                    attribute:NSLayoutAttributeBottom
                                    relatedBy:NSLayoutRelationEqual
                                    toItem:self.rootController.view
                                    attribute:NSLayoutAttributeBottom
                                    multiplier:1
                                    constant:0]];
    }
    
    [Utils logAdmob:self.adName message:@"bannerView height: %f", self.bannerView.bounds.size.height];
    [Utils logAdmob:self.adName message:@"bannerView width: %f", self.bannerView.bounds.size.width];
}

- (int)getHeight {
    if (self.bannerView) {
        return self.bannerView.bounds.size.height;
    }
    return -1;
}

- (int)getHeightInPixels {
    if (self.bannerView) {
        return self.bannerView.bounds.size.height * [UIScreen mainScreen].scale;
    }
    return -1;
}

- (int)getWidth {
    if (self.bannerView) {
        return self.bannerView.bounds.size.width;
    }
    return -1;
}

- (int)getWidthInPixels {
    if (self.bannerView) {
        return self.bannerView.bounds.size.width * [UIScreen mainScreen].scale;
    }
    return -1;
}

#pragma mark - Ad Callbacks
- (void)bannerViewDidReceiveAd:(GADBannerView *)bannerView {
    [self setBannerConstraints];
    [Utils logAdmob:self.adName message:@"Load Success."];
    [AdCallbackHandler adLoadSuccess:self.adName];
    self.isLoaded = YES;
}

- (void)bannerView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(NSError *)error {
    [Utils logAdmob:self.adName message:@"Load Failure. %@", error.localizedDescription];
    [AdCallbackHandler adLoadFailure:self.adName error:error];
}

- (void)bannerViewDidRecordImpression:(GADBannerView *)bannerView {
    [AdCallbackHandler adImpressionReceived:self.adName];
    [Utils logAdmob:self.adName message:@"Ad Recorded Impression."];
}

- (void)bannerViewDidRecordClick:(GADBannerView *)bannerView {
    [AdCallbackHandler adClicked:self.adName];
    [Utils logAdmob:self.adName message:@"Ad Clicked."];
}

#pragma mark - Ad Callbacks related to Fullscreen banner only
- (void)bannerViewWillPresentScreen:(GADBannerView *)bannerView {}
- (void)bannerViewDidDismissScreen:(GADBannerView *)bannerView {}
- (void)bannerViewWillDismissScreen:(GADBannerView *)bannerView {}

@end
