//
//  UtilitiesImplementation.h
//  Utilities
//
//  Created by Samrat Singh on 16/10/2025.
//

#include "Utilities.h"
#include <Foundation/Foundation.h>
#include "core/engine.h"
#include "core/object.h"
#include "GdObjcTypeBridge.h"

class Utilities: public Object {
    GDCLASS(Utilities, Object);
    
    static void _bind_methods();
    
public:
    static Utilities *instance;
    
    String get_version_code();
    String get_version_name();
    
    Utilities();
    ~Utilities();
    
    static Utilities *get_singleton();
};
