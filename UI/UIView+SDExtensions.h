//
//  UIView+SDExtensions.h
//  walmart
//
//  Created by Sam Grover on 2/27/11.
//  Copyright 2011 Set Direction. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIView (SDExtensions)

@property (nonatomic, assign) CGPoint integralCenter; // Ensures frame is positioned on pixels
@property (nonatomic, assign) CGRect integralFrame; // Ensures frame is positioned on pixels

// Layout
- (void)positionBelowView:(UIView *)argView offset:(CGFloat)argOffset;

// Frame adjustment
-(void)setFrameOriginY:(CGFloat)newY;
-(void)setFrameOriginX:(CGFloat)newX;


@end
