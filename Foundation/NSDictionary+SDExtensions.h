//
//  NSMutableDictionary+SDExtensions.h
//  walmart
//
//  Created by Brandon Sneed on 6/27/11.
//  Copyright 2011 Set Direction. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (NSMutableDictionary_SDExtensions)

- (NSString *)stringForKey:(NSString *)key;
- (NSInteger)intForKey:(NSString *)key;
- (NSInteger)integerForKey:(NSString *)key;
- (NSUInteger)unsignedIntForKey:(NSString *)key;
- (NSUInteger)unsignedIntegerForKey:(NSString *)key;
- (NSInteger)floatForKey:(NSString *)key;
- (NSInteger)doubleForKey:(NSString *)key;
- (long long)longLongForKey:(NSString *)key;
- (BOOL)boolForKey:(NSString *)key;

@end
