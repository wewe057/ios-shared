//
//  UIView+SDExtensions.h
//  walmart
//
//  Created by Sam Grover on 2/27/11.
//  Copyright 2011 Set Direction. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIView (SDExtensions)

/**
 Set this to ensure that the center is positioned on full pixels. Read to see the closest integral center to the receiver's center.
 */
@property (nonatomic, assign) CGPoint integralCenter;

/**
 Set this to ensures that the frame is positioned on full pixels. Read to see the closest integral frame to the receiver's frame.
 */
@property (nonatomic, assign) CGRect integralFrame;

/**
 Adjusts the receiver's frame to move it below `argOffset` pixels below the view passed in as `argView`. Other aspects of the frame are not changed.
 */
- (void)positionBelowView:(UIView *)argView offset:(CGFloat)argOffset;

/**
 Convenience method to set the receiver's `frame.origin.y`.
 */
- (void)setFrameOriginY:(CGFloat)newY;

/**
 Convenience method to set the receiver's `frame.origin.x`.
 */
- (void)setFrameOriginX:(CGFloat)newX;

/**
 Returns the first subview that is of the type of `aViewClass`. Returns `nil` if there's none found.
 */
- (id)firstSubviewOfClass:(Class)aViewClass;

/**
 Returns a visual stand-in for the current view that can be shown in it's place.
 */
- (UIView *)snapshot;

/**
 Returns a UIImage representation of a view and it's subview heirarchy.
 */
- (UIImage *)screenshot;


@end
