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

// Returns the OS version as BCD stored in a 4 byte unsigned integer.
// Here is an example of it's use:
//
//   if ([UIDevice bcdSystemVersion] >= 0x040301)
//
// Which will check to see if the device is running an OS of 4.3.1 or higher.

+ (uint32_t)bcdSystemVersion;

@end
