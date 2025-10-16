//
//  GoogleAdmob.m
//  GoogleAdmob
//
//  Created by Samrat Singh on 19/09/2025.
//

#import "GoogleAdmob.h"

GoogleAdmob *admob;
void godot_admob_init() {
    NSLog(@"GoogleAdmob init plugin");

    admob = memnew(GoogleAdmob);
    Engine::get_singleton()->add_singleton(Engine::Singleton("GoogleAdmob", admob));
}

void godot_admob_deinit() {
    NSLog(@"GoogleAdmob deinit plugin");
    
    if (admob && admob != nullptr) {
       memdelete(admob);
   }
    NSLog(@"GoogleAdmob deinit plugin succesful");
    sleep(10);
}
