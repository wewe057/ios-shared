//
//  NSNumber+SDExtensions.h
//  SamsClub
//
//  Created by Sam Grover on 6/28/13.
//  Copyright (c) 2013 Wal-mart Stores, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNumber (SDExtensions)

/**
 Takes a string of format $1,000,000.00 and returns an NSNumber.
 */
+ (NSNumber *)numberFromDollarString:(NSString *)argDollarString;

@end
