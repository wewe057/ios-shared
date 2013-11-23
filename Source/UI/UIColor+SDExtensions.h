//
//  UIColor+SDExtensions.h
//  SetDirection
//
//  Created by Sam Grover on 3/19/11.
//  Copyright 2011 SetDirection. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIColor (SDExtensions)

/**
 A convenience method to create and return a UIColor object using the standard RGB values that range from `0.0` to `255.0` each.
 */
+ (UIColor *)colorWith8BitRed:(NSUInteger)red green:(NSUInteger)green blue:(NSUInteger)blue alpha:(CGFloat)alpha;
+ (UIColor *)colorWithHexString:(NSString *)hexString;

@end
