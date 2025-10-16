//
//  Utils.h
//  GoogleAdmob
//
//  Created by Samrat Singh on 25/09/2025.
//

#import "GoogleAdmobImplementation.h"

@interface Utils: NSObject
+(NSString*)getAdmobType:(NSString*)adName;
+(NSString*)getAdUnitId:(NSString*)adName;
+(void)logAdmob:(NSString*)adName message:(NSString*)message, ...;
+(BaseAd*)getAdObj:(NSString*)adName;
@end
