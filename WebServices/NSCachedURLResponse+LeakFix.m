//
//  NSCachedURLResponse+LeakFix.m
//  walmart
//
//  Created by Brandon Sneed on 4/29/12.
//  Copyright (c) 2012 Walmart. All rights reserved.
//

#import "NSCachedURLResponse+LeakFix.h"

@implementation NSCachedURLResponse (LeakFix)

- (NSData *)responseData
{
    NSData *result = nil;
    
    NSUInteger firstCount = CFGetRetainCount((__bridge CFTypeRef)self.data);
    NSUInteger secondCount = CFGetRetainCount((__bridge CFTypeRef)self.data);
    result = self.data;

    if (firstCount != secondCount)
    {
        // this os build has the leak...  commence bullshit.
        
        // release our 3 total accesses that incurred a retain.
        CFRelease((__bridge CFTypeRef)result);
        CFRelease((__bridge CFTypeRef)result);
        CFRelease((__bridge CFTypeRef)result);
    }
    
    return result;
}

@end
