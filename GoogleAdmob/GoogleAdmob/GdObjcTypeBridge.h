//
//  GdObjcTypeBridge.h
//  GoogleAdmob
//
//  Created by Samrat Singh on 23/09/2025.
//

#include "Foundation/Foundation.h"
#include "core/engine.h"

@interface GdObjcTypeBridge : NSObject
+(NSString*) to_nsstring:(String) str;
+(String) from_nsstring:(NSString*) str;
+(NSDictionary*) to_nsdictionary:(Dictionary) dic;
+(NSArray*) to_nsarray:(Array) arr;
+(Array) from_nsarray:(NSArray*) array;
+(Dictionary) from_nsdictionary:(NSDictionary*) dic;
+(Variant) nsobject_to_variant:(NSObject*) object;
+(NSObject*) variant_to_nsobject:(Variant) v;
@end
