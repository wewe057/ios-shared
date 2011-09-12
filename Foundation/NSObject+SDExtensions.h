//
//  NSObject+SDExtensions.h
//  walmart
//
//  Created by Brandon Sneed on 9/12/11.
//  Copyright (c) 2011 Walmart. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject_SDExtensions : NSObject

- (void)callSelector:(SEL)aSelector returnAddress:(void *)result argumentAddresses:(void *)arg1, ...;

@end
