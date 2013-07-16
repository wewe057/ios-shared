//
//  UIImage+SDExtensions.h
//  walmart
//
//  Created by Brandon Sneed on 10/5/11.
//  Copyright (c) 2011 Walmart. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (SDExtensions)

/**
 Returns a UIImage rendering of the passed in view.
 */
+ (UIImage *)imageFromView:(UIView *)view;
- (UIImage *)nonJaggyImage;

@end
