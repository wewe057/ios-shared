//
//  UIColor+SDExtensions.m
//  SetDirection
//
//  Created by Sam Grover on 3/19/11.
//  Copyright 2011 SetDirection. All rights reserved.
//

#import "UIColor+SDExtensions.h"


@implementation UIColor (SDExtensions)

+ (UIColor *)colorWith8BitRed:(NSUInteger)red green:(NSUInteger)green blue:(NSUInteger)blue alpha:(CGFloat)alpha
{
	return [UIColor colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:alpha];
}

@end
