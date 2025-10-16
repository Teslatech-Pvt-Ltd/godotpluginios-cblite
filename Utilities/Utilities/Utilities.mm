//
//  Utilities.m
//  Utilities
//
//  Created by Samrat Singh on 16/10/2025.
//

#import "Utilities.h"
#import "UtilitiesImplementation.h"

Utilities *utilities;
void utilities_init() {
    NSLog(@"Utilities Plugin Init.");
    
    utilities = memnew(Utilities);
    Engine::get_singleton()->add_singleton(Engine::Singleton("Utilities", utilities));
}

void utilities_deinit() {
    NSLog(@"Utilities Plugin Deinit.");
    if(utilities) {
        memdelete(utilities);
    }
}
