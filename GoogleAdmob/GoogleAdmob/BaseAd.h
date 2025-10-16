//
//  BaseAd.h
//  GoogleAdmob
//
//  Created by Samrat Singh on 19/09/2025.
//

#include "Foundation/Foundation.h"

enum class AdPosition {
    Bottom,
    Top,
    Left,
    Center,
    Right,
    TopLeft,
    TopRight,
    BottomLeft,
    BottomRight,
    Custom = -1
};

@interface BaseAd : NSObject

@property NSString* adUnitId;
@property NSString* adName;
@property BOOL isVisible;
@property BOOL isLoaded;

-(instancetype)init;
-(void)loadAd:(NSString*)adName;
-(void)showAd;
-(void)hideAd;
-(void)destroyAd;
-(bool)isAdLoaded;
-(bool)isAdVisible;
-(int)getWidth;
-(int)getHeight;
-(int)getWidthInPixels;
-(int)getHeightInPixels;

@end
