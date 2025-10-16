//
//  BaseAd.mm
//  GoogleAdmob
//
//  Created by Samrat Singh on 22/09/2025.
//

#include "BaseAd.h"


@implementation BaseAd
- (int)getHeight {return -1;}
- (int)getHeightInPixels {return -1;}
- (int)getWidth {return -1;}
- (int)getWidthInPixels {return -1;}
- (instancetype)init {return self;}
- (bool)isAdLoaded {return false;}
- (bool)isAdVisible {return false;}
- (void)loadAd:(NSString *)adName {}
- (void)showAd {}
- (void)destroyAd {}
- (void)hideAd {}

@end
