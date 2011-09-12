//
//  NSArray+SDExtensions.h
//  navbar2
//
//  Created by Brandon Sneed on 7/26/11.
//  Copyright 2011 Walmart. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (NSArray_SDExtensions)

- (id)nextToLastObject;
- (void)callSelector:(SEL)aSelector argumentAddresses:(void *)arg1, ...;

@end
