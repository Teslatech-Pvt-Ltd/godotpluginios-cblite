//
//  FirebaseRemoteConfig.h
//  GodotFirebaseRemoteConfig
//
//  Created by Samrat Singh on 03/06/2025.
//

#import <Foundation/Foundation.h>
#define SIGNAL_ACTIVATE "activated"
#define SIGNAL_FETCHED "fetched"
#define SIGNAL_IMMEDIATE_FETCHED "immediate_fetched"

void firebase_remote_init(void);
void firebase_remote_deinit(void);
