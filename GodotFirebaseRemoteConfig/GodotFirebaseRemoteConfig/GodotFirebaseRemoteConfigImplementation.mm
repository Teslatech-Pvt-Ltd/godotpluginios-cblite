//
//  Untitled.h
//  GodotFirebaseRemoteConfig
//
//  Created by Samrat Singh on 03/06/2025.
//

#import <Foundation/Foundation.h>

#include "core/project_settings.h"
#include "core/class_db.h"
#include "GodotFirebaseRemoteConfig.h"
#include "GodotFirebaseRemoteConfigImplementation.h"
#include "FirebaseRemoteConfig/FirebaseRemoteConfig.h"
#include "FirebaseCore/FIRApp.h"

void FirebaseRemoteConfig::_bind_methods() {
    ClassDB::bind_method(D_METHOD("init"), &FirebaseRemoteConfig::initialize);
    ClassDB::bind_method(D_METHOD("set_default_config"), &FirebaseRemoteConfig::set_default_config);
    ClassDB::bind_method(D_METHOD("activate"), &FirebaseRemoteConfig::activate);
    ClassDB::bind_method(D_METHOD("fetch"), &FirebaseRemoteConfig::fetch);
    ClassDB::bind_method(D_METHOD("get_string"), &FirebaseRemoteConfig::get_string);
    ClassDB::bind_method(D_METHOD("get_boolean"), &FirebaseRemoteConfig::get_boolean);
    ClassDB::bind_method(D_METHOD("get_int"), &FirebaseRemoteConfig::get_int);
    ClassDB::bind_method(D_METHOD("get_double"), &FirebaseRemoteConfig::get_double);
    ClassDB::bind_method(D_METHOD("fetch_immediately"), &FirebaseRemoteConfig::fetch_immediately);
    
    ADD_SIGNAL(MethodInfo(SIGNAL_ACTIVATE));
    ADD_SIGNAL(MethodInfo(SIGNAL_FETCHED));
    ADD_SIGNAL(MethodInfo(SIGNAL_IMMEDIATE_FETCHED));
}

FIRRemoteConfig *firebaseRemoteConfig;

Variant nsobject_to_variant(NSObject *object);
NSObject *variant_to_nsobject(Variant v);

NSString* to_nsstring(String str) {
    return [[NSString alloc] initWithUTF8String:str.utf8().get_data()];
}


String from_nsstring(NSString* str) {
    const char *s = [str UTF8String];
    return String::utf8(s != NULL ? s : "");
}

NSDictionary* to_nsdictionary(Dictionary dic) {
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    Array keys = dic.keys();
    for (int i = 0; i < keys.size(); ++i) {
        NSString *key = [[NSString alloc] initWithUTF8String:((String)(keys[i])).utf8().get_data()];
        NSObject *value = variant_to_nsobject(dic[keys[i]]);

        if (key == NULL || value == NULL) {
            return NULL;
        }

        [result setObject:value forKey:key];
    }
    return result;
}


NSArray* to_nsarray(Array arr) {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (int i = 0; i < arr.size(); ++i) {
        NSObject *value = variant_to_nsobject(arr[i]);
        if (value != NULL) {
            [result addObject:value];
        } else {
            WARN_PRINT("Trying to add something unsupported to the array.");
        }
    }
    return result;
}

Array from_nsarray(NSArray* array) {
    Array result;
    for (NSUInteger i = 0; i < [array count]; ++i) {
        NSObject *value = [array objectAtIndex:i];
        result.push_back(nsobject_to_variant(value));
    }
    return result;
}

Dictionary from_nsdictionary(NSDictionary* dic) {
    Dictionary result;

    NSArray *keys = [dic allKeys];
    long count = [keys count];
    for (int i = 0; i < count; ++i) {
        NSObject *k = [keys objectAtIndex:i];
        NSObject *v = [dic objectForKey:k];

        result[nsobject_to_variant(k)] = nsobject_to_variant(v);
    }
    return result;
}

Variant nsobject_to_variant(NSObject *object) {
    if ([object isKindOfClass:[NSString class]]) {
        return from_nsstring((NSString *)object);
    } else if ([object isKindOfClass:[NSData class]]) {
        PoolByteArray ret;
        NSData *data = (NSData *)object;
        if ([data length] > 0) {
            ret.resize([data length]);
            {
                // PackedByteArray::Write w = ret.write();
                memcpy((void *)ret.read().ptr(), [data bytes], [data length]);
            }
        }
        return ret;
    } else if ([object isKindOfClass:[NSArray class]]) {
        return from_nsarray((NSArray *)object);
    } else if ([object isKindOfClass:[NSDictionary class]]) {
        return from_nsdictionary((NSDictionary *)object);
    } else if ([object isKindOfClass:[NSNumber class]]) {
        //Every type except numbers can reliably identify its type.  The following is comparing to the *internal* representation, which isn't guaranteed to match the type that was used to create it, and is not advised, particularly when dealing with potential platform differences (ie, 32/64 bit)
        //To avoid errors, we'll cast as broadly as possible, and only return int or float.
        //bool, char, int, uint, longlong -> int
        //float, double -> float
        NSNumber *num = (NSNumber *)object;
        if (strcmp([num objCType], @encode(BOOL)) == 0) {
            return Variant((int)[num boolValue]);
        } else if (strcmp([num objCType], @encode(char)) == 0) {
            return Variant((int)[num charValue]);
        } else if (strcmp([num objCType], @encode(int)) == 0) {
            return Variant([num intValue]);
        } else if (strcmp([num objCType], @encode(unsigned int)) == 0) {
            return Variant((int)[num unsignedIntValue]);
        } else if (strcmp([num objCType], @encode(long long)) == 0) {
            return Variant((int)[num longValue]);
        } else if (strcmp([num objCType], @encode(float)) == 0) {
            return Variant([num floatValue]);
        } else if (strcmp([num objCType], @encode(double)) == 0) {
            return Variant((float)[num doubleValue]);
        } else {
            return Variant();
        }
    } else if ([object isKindOfClass:[NSDate class]]) {
        //this is a type that icloud supports...but how did you submit it in the first place?
        //I guess this is a type that *might* show up, if you were, say, trying to make your game
        //compatible with existing cloud data written by another engine's version of your game
        WARN_PRINT("NSDate unsupported, returning null Variant");
        return Variant();
    } else if ([object isKindOfClass:[NSNull class]] or object == nil) {
        return Variant();
    } else {
        WARN_PRINT("Trying to convert unknown NSObject type to Variant");
        return Variant();
    }
}

NSObject *variant_to_nsobject(Variant v) {
    if (v.get_type() == Variant::STRING) {
        return to_nsstring((String)v);
    } else if (v.get_type() == Variant::REAL) {
        return [NSNumber numberWithDouble:(double)v];
    } else if (v.get_type() == Variant::INT) {
        return [NSNumber numberWithLongLong:(long)(int)v];
    } else if (v.get_type() == Variant::BOOL) {
        return [NSNumber numberWithBool:BOOL((bool)v)];
    } else if (v.get_type() == Variant::DICTIONARY) {
        return to_nsdictionary(v);
    } else if (v.get_type() == Variant::ARRAY) {
        return to_nsarray(v);
    } else if (v.get_type() == Variant::POOL_BYTE_ARRAY) {
        PoolByteArray arr = v;
        // PackedByteArray::Read r = arr.read();
        NSData *result = [NSData dataWithBytes:arr.read().ptr() length:arr.size()];
        return result;
    }
    WARN_PRINT(String("Could not add unsupported type to iCloud: '" + Variant::get_type_name(v.get_type()) + "'").utf8().get_data());
    return NULL;
}



void FirebaseRemoteConfig::initialize(){
    firebaseRemoteConfig = [FIRRemoteConfig remoteConfig];
    FIRRemoteConfigSettings *remoteConfigSettings = [[FIRRemoteConfigSettings alloc] init];
    remoteConfigSettings.minimumFetchInterval = 0;
    firebaseRemoteConfig.configSettings = remoteConfigSettings;
}

void FirebaseRemoteConfig::set_default_config(Dictionary defs){
    [firebaseRemoteConfig setDefaults: to_nsdictionary(defs)];
}

void FirebaseRemoteConfig::activate(){
    NSLog(@"GodotPlugin Log: Activate Method Called");
    [firebaseRemoteConfig activateWithCompletion:^(BOOL changed, NSError * _Nullable error) {
      if (error != nil) {
        NSLog(@"GodotPlugin Log: Activate error: %@", error.localizedDescription);
      } else {
          NSLog(@"GodotPlugin Log: Config Activated");
          dispatch_async(dispatch_get_main_queue(), ^{
              emit_signal(SIGNAL_ACTIVATE);
          });
      }
    }];
   
}

void FirebaseRemoteConfig::fetch(){
    NSLog(@"GodotPlugin Log: Fetch Method Called");
    [firebaseRemoteConfig fetchWithCompletionHandler:^(FIRRemoteConfigFetchStatus status, NSError *error) {
        if (status == FIRRemoteConfigFetchStatusSuccess) {
            NSLog(@"GodotPlugin Log: Config fetched!");
            emit_signal(SIGNAL_FETCHED);
        } else {
            NSLog(@"GodotPlugin Log: Config not fetched");
            NSLog(@"GodotPlugin Log: Error %@", error.localizedDescription);
        }
    }];
}

void FirebaseRemoteConfig::fetch_immediately() {
    NSLog(@"GodotPlugin Log: Fetch Immediately Method Called");
    [firebaseRemoteConfig fetchWithCompletionHandler:^(FIRRemoteConfigFetchStatus status, NSError *error) {
        if (status == FIRRemoteConfigFetchStatusSuccess) {
            NSLog(@"GodotPlugin Log: Config fetched!");
            emit_signal(SIGNAL_IMMEDIATE_FETCHED, true);
        } else {
            NSLog(@"GodotPlugin Log: Config Fetch Failed Error %@", error.localizedDescription);
            emit_signal(SIGNAL_IMMEDIATE_FETCHED, false);
        }
    }];
}

String FirebaseRemoteConfig::get_string(String pname){
    NSString *keyName = [NSString stringWithCString:String(pname).utf8().get_data() encoding:NSUTF8StringEncoding];
    NSLog(@"RemoteConfigPlugin Get String: %@", firebaseRemoteConfig[keyName].stringValue);
    return from_nsstring(firebaseRemoteConfig[keyName].stringValue);
}

bool FirebaseRemoteConfig::get_boolean(String pname){
    NSString *keyName = [NSString stringWithCString:String(pname).utf8().get_data() encoding:NSUTF8StringEncoding];
    NSLog(@"RemoteConfigPlugin Get Bool: %s",(firebaseRemoteConfig[keyName].boolValue ? "1" : "0"));
    return firebaseRemoteConfig[keyName].boolValue;
}

int FirebaseRemoteConfig::get_int(String pname){
    NSString *keyName = [NSString stringWithCString:String(pname).utf8().get_data() encoding:NSUTF8StringEncoding];
    NSLog(@"RemoteConfigPlugin Get Int: %@", firebaseRemoteConfig[keyName].numberValue);
    return [firebaseRemoteConfig[keyName].numberValue intValue];
}

float FirebaseRemoteConfig::get_double(String pname){
    NSString *keyName = [NSString stringWithCString:String(pname).utf8().get_data() encoding:NSUTF8StringEncoding];
    NSLog(@"RemoteConfigPlugin Get Float: %@", firebaseRemoteConfig[keyName].numberValue);
    return [firebaseRemoteConfig[keyName].numberValue floatValue];
}

__attribute__((constructor))
static void forceFirebase() {
    [FIRApp class];
}

FirebaseRemoteConfig::FirebaseRemoteConfig() {
    if (FIRApp.defaultApp == nil) {
        [FIRApp configure];
    }
}

FirebaseRemoteConfig::~FirebaseRemoteConfig() {
}
