//
//  UIDevice+machine.m
//  walmart
//
//  Created by Justin Zealand on 4/1/11.
//  Copyright 2011 Set Direction. All rights reserved.
//
//  Based upon http://iphonedevelopertips.com/device/determine-if-iphone-is-3g-or-3gs-determine-if-ipod-is-first-or-second-generation.html

#import "UIDevice+machine.h"
#include <sys/types.h>
#include <sys/sysctl.h>

@implementation UIDevice(machine)

- (NSString *)machine
{
    size_t size;
    
    // Set 'oldp' parameter to NULL to get the size of the data
    // returned so we can allocate appropriate amount of space
    sysctlbyname("hw.machine", NULL, &size, NULL, 0); 
    
    // Allocate the space to store name
    char *name = malloc(size);
    
    // Get the platform name
    sysctlbyname("hw.machine", name, &size, NULL, 0);
    
    // Place name into a string
    NSString *machine = [NSString stringWithUTF8String:name];
	
	free(name);
	
    return machine;
}

+ (BOOL)systemVersionGreaterThanOrEqualToVersion:(NSString *)minVersion 
{
    NSString *sysVersion = [[UIDevice currentDevice] systemVersion];
	NSComparisonResult result = [sysVersion compare:minVersion options:NSNumericSearch];
	if (result == NSOrderedDescending || result == NSOrderedSame)
		return YES;
    return NO;
}

+ (BOOL)systemVersionLessThanVersion:(NSString *)minVersion 
{
    if ([UIDevice systemVersionGreaterThanOrEqualToVersion:minVersion])
		return NO;
	return YES;
}


@end
