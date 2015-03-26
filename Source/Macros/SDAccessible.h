//
//  SDAccessible.h
//  walmart
//
//  Created by Cody Garvin on 3/26/15.
//  Copyright (c) 2015 Walmart. All rights reserved.
//

#import <Foundation/Foundation.h>

/// Redefinition of NSAssert to allow checking if assertions should run while
/// in debug mode. @see SDAssertProcess
#if defined(DEBUG)
#define SDAccessible(view, accessibilityLabel)	\
    do {				\
        __PRAGMA_PUSH_NO_EXTRA_ARG_WARNINGS \
        if (!(condition) && !SDAssertProcess()) {		\
[[NSAssertionHandler currentHandler] handleFailureInMethod:_cmd \
object:self file:[NSString stringWithUTF8String:__FILE__] \
lineNumber:__LINE__ description:(desc), ##__VA_ARGS__]; \
}				\
        __PRAGMA_POP_NO_EXTRA_ARG_WARNINGS \
    } while(0)

#else
#define SDAssert(x...)
#endif