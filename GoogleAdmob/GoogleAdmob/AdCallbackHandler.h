//
//  AdCallbackHandler.h
//  GoogleAdmob
//
//  Created by Samrat Singh on 25/09/2025.
//

#include "Foundation/Foundation.h"


@interface AdCallbackHandler : NSObject

+(void)adLoadSuccess:(NSString*)adName;
+(void)adLoadFailure:(NSString*)adName error:(NSError*)error;
+(void)adShowSuccess:(NSString*)adName;
+(void)adShowFailure:(NSString*)adName error:(NSError*)error;
+(void)adDismiss:(NSString*)adName;
+(void)adClicked:(NSString*)adName;
+(void)adImpressionReceived:(NSString*)adName;
+(void)adEnded:(NSString*)adName;

@end
