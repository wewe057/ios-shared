//
//  NSNumber+SDExtensions.m
//  SamsClub
//
//  Created by Sam Grover on 6/28/13.
//  Copyright (c) 2013 Wal-mart Stores, Inc. All rights reserved.
//

#import "NSNumber+SDExtensions.h"

@implementation NSNumber (SDExtensions)

+ (NSNumber *)numberFromDollarString:(NSString *)argDollarString
{
    static NSNumberFormatter *sFormatter = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sFormatter = [[NSNumberFormatter alloc] init];
        [sFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    });
    
    return [sFormatter numberFromString:argDollarString];
}


@end
