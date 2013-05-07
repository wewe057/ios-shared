//
//  UIDevice+machine.h
//  walmart
//
//  Created by Justin Zealand on 4/1/11.
//  Copyright 2011 Set Direction. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIDevice(machine)

- (NSString *)machine;
+ (BOOL)systemVersionGreaterThanOrEqualToVersion:(NSString *)minVersion;
+ (BOOL)systemVersionLessThanVersion:(NSString *)minVersion;

@end
