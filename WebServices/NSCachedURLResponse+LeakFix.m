//
//  NSCachedURLResponse+LeakFix.m
//  SetDirection
//
//  Created by Brandon Sneed on 4/29/12.
//  Copyright (c) 2012-2013 SetDirection. All rights reserved.
//

#import "NSCachedURLResponse+LeakFix.h"

@implementation NSCachedURLResponse (LeakFix)

#ifndef __clang_analyzer__

- (NSData *)responseData
{
    NSData *result = nil;

    __unsafe_unretained NSData *first = self.data;
    NSInteger firstCount = CFGetRetainCount((__bridge CFTypeRef)first);
    __unsafe_unretained NSData *second = self.data;
    NSInteger secondCount = CFGetRetainCount((__bridge CFTypeRef)second);
    result = first;

    if (first == second)
    {
        if (firstCount != secondCount)
        {
            // this os build has the leak...  commence serious bullshit.
            
            // release our 2 total accesses that incurred a retain.
            CFRelease((__bridge CFTypeRef)result);
            CFRelease((__bridge CFTypeRef)result);
        }
    }    
    return result;
}

#endif

@end
