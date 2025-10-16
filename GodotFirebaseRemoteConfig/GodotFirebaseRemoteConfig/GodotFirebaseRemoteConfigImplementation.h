//
//  GodotFirebaseRemoteConfigImplementation.h
//  GodotFirebaseRemoteConfig
//
//  Created by Samrat Singh on 03/06/2025.
//

#ifndef GodotFirebaseRemoteConfigImplementation_h
#define GodotFirebaseRemoteConfigImplementation_h
#include "core/object.h"
#include "GodotFirebaseRemoteConfig.h"
#include "core/engine.h"

class FirebaseRemoteConfig : public Object {
    GDCLASS(FirebaseRemoteConfig, Object);
    
    static void _bind_methods();
    
public:
    
    void get_app_version();
    void initialize();
    void set_default_config(Dictionary defs);
    void activate();
    void fetch();
    void fetch_immediately();
    String get_string(String pname);
    bool get_boolean(String pname);
    int get_int(String pname);
    float get_double(String pname);
    
    FirebaseRemoteConfig();
    ~FirebaseRemoteConfig();
};

#endif /* GetAppVersionImplementation_h */

