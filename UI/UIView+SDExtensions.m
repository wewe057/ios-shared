//
//  UIView+SDExtensions.m
//  walmart
//
//  Created by Sam Grover on 2/27/11.
//  Copyright 2011 Set Direction. All rights reserved.
//

#import "UIView+SDExtensions.h"


@implementation UIView (SDExtensions)

- (void)positionBelowView:(UIView *)argView offset:(CGFloat)argOffset
{
	CGRect theFrame = argView.frame;
	theFrame = CGRectMake(theFrame.origin.x, theFrame.origin.y + argView.frame.size.height + argOffset, self.frame.size.width, self.frame.size.height);
	self.frame = theFrame;
}

@end
