//
//  UIColor+SDExtension.m
//  SetDirection
//
//  Created by Steven Woolgar on 11/25/2013.
//  Copyright 2013 SetDirection. All rights reserved.
//

#import "NSString+SDExtensions.h"

#include <sys/types.h>
#include <sys/sysctl.h>

@implementation UIColor(SDExtensionWebDesigners)

/*
 * Returns a UIColor objects for the string's hex representation:
 *
 * For example: [@"#fff" uicolor] returns a UIColor of white.
 *              [@"#118653" uicolor] returns something green.
 *              [@"#1186537F" uicolor] returns something green with a 50% alpha value
 */
+ (UIColor *)colorWithHexValue:(NSString *)hexValueString;
{
    UIColor *color = [hexValueString uicolor];
    return color;
}

@end
