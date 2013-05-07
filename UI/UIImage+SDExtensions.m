//
//  UIImage+SDExtensions.m
//  walmart
//
//  Created by Brandon Sneed on 10/5/11.
//  Copyright (c) 2011 Walmart. All rights reserved.
//

#import "UIImage+SDExtensions.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIImage (SDExtensions)

+ (UIImage *)imageFromView:(UIView *)view
{
    UIImage *result = nil;
    
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0.0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:ctx];
    for (CALayer *layer in view.layer.sublayers)
    {
        [layer renderInContext:ctx];
    }
    result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}

@end
