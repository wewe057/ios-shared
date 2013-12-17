//
//  UIImage+SDExtensions.h
//  SetDirection
//
//  Using this now involves adding in the Accelerate.framework.
//
//  Created by Brandon Sneed on 10/5/11.
//  Copyright (c) 2011 SetDirection. All rights reserved.
//  Some parts Copyright (C) 2013 Apple Inc. All Rights Reserved.  WWDC 2013 License
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

/**
 Composite a supplied image on top of the image this is being called at.
 You also tell it where to draw inside of the rect of the image you are overlaying.
 */
- (UIImage *)compositeWith:(UIImage *)overlayImage toPoint:(CGPoint)overlayPoint;

- (UIImage *)applyLightEffect;
- (UIImage *)applyExtraLightEffect;
- (UIImage *)applyDarkEffect;
- (UIImage *)applyTintEffectWithColor:(UIColor *)tintColor;

- (UIImage *)applyBlurWithRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage;

@end
