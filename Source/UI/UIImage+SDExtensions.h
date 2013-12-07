//
//  UIImage+SDExtensions.h
//  SetDirection
//
//  Created by Brandon Sneed on 10/5/11.
//  Copyright (c) 2011 SetDirection. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (SDExtensions)

/**
 Returns a UIImage rendering of the passed in view.
 */
+ (UIImage *)imageFromView:(UIView *)view;
- (UIImage *)nonJaggyImage;

/**
 Returns a UIColor approximating the averaged color of an image.
 */
- (UIColor*) averageColor;

/**
 Returns a UIImage filled with the supplied color of the request size.
 */
+ (UIImage *)filledImageWithFrame:(CGSize)size andColor:(UIColor *)color;

@end
