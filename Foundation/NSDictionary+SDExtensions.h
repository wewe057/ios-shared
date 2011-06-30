//
//  NSDictionary+SDExtensions.h
//  walmart
//
//  Created by Brandon Sneed on 6/27/11.
//  Copyright 2011 Set Direction. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (NSDictionary_SDExtensions)

- (NSString *)stringForKey:(NSString *)key;
- (NSInteger)intForKey:(NSString *)key;
- (NSInteger)integerForKey:(NSString *)key;
- (NSUInteger)unsignedIntForKey:(NSString *)key;
- (NSUInteger)unsignedIntegerForKey:(NSString *)key;
- (float)floatForKey:(NSString *)key;
- (double)doubleForKey:(NSString *)key;
- (long long)longLongForKey:(NSString *)key;
- (BOOL)boolForKey:(NSString *)key;

@end
