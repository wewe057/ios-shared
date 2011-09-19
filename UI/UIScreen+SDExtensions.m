//
//  UIScreen+SDExtensions.m
//  walmart
//
//  Created by Sam Grover on 9/19/11.
//  Copyright 2011 Walmart. All rights reserved.
//

#import "UIScreen+SDExtensions.h"

@implementation UIScreen (SDExtensions)

+ (BOOL)hasRetinaDisplay
{
	if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2)
		return YES;
	else
		return NO;
}

@end
