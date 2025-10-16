//
//  GodotFirebaseRemoteConfig.m
//  GodotFirebaseRemoteConfig
//
//  Created by Teslatech on 16/08/2022.
//

#import <Foundation/Foundation.h>
#import "GodotFirebaseRemoteConfig.h"
#import "GodotFirebaseRemoteConfigImplementation.h"
#import "GodotFirebaseRemoteConfigImplementation.mm"
#import "core/engine.h"

FirebaseRemoteConfig *remoteConfig;

void firebase_remote_init() {
    NSLog(@"init plugin");

    remoteConfig = memnew(FirebaseRemoteConfig);
    Engine::get_singleton()->add_singleton(Engine::Singleton("FirebaseRemoteConfig", remoteConfig));
    
}

void firebase_remote_deinit() {
    NSLog(@"deinit plugin");
    
    if (remoteConfig) {
       memdelete(remoteConfig);
   }
    
}
