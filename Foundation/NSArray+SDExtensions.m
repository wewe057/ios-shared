//
//  NSArray+SDExtensions.m
//  navbar2
//
//  Created by Brandon Sneed on 7/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSArray+SDExtensions.h"

@implementation NSArray (NSArray_SDExtensions)

- (id)nextToLastObject
{
    int count = [self count];
    if (count < 2)
        return nil;
    id result = [self objectAtIndex:count-2];
    return result;
}

@end
