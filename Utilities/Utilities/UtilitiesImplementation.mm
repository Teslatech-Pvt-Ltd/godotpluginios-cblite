//
//  UtilitiesImplementation.mm
//  Utilities
//
//  Created by Samrat Singh on 16/10/2025.
//

#import "Utilities.h"
#import "UtilitiesImplementation.h"
#include "core/engine.h"

Utilities* Utilities::instance = nullptr;
Utilities *Utilities::get_singleton() {
    return instance;
}

void Utilities::_bind_methods() {
    ClassDB::bind_method(D_METHOD("get_version_code"), &Utilities::get_version_code);
    ClassDB::bind_method(D_METHOD("get_version_name"), &Utilities::get_version_name);
    
    NSLog(@"[Utilities] Methods binding completed");
}

String Utilities::get_version_name() {
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSLog(@"[Utilities] CB Version Name: %@", version);
    return [GdObjcTypeBridge from_nsstring:version];
}

String Utilities::get_version_code() {
    NSString *versionCode = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSLog(@"[Utilities] CB Version Code: %@", versionCode);
    return [GdObjcTypeBridge from_nsstring:versionCode];
}
