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
	self.frame = CGRectMake(self.frame.origin.x,
							argView.frame.origin.y + argView.frame.size.height + argOffset,
							self.frame.size.width,
							self.frame.size.height);
}

-(void)setFrameOriginY:(CGFloat)newY
{
	CGRect f = self.frame;
	f.origin.y = newY;
	self.frame = f;
}

-(void)setFrameOriginX:(CGFloat)newX
{
	CGRect f = self.frame;
	f.origin.x = newX;
	self.frame = f;
}

-(void)setIntegralCenter:(CGPoint)integralCenter
{
//	CGRect integralFrame = self.frame;
//	integralFrame.origin.x = integralCenter.x - (integralFrame.size.width / 2);
//	integralFrame.origin.y = integralCenter.y - (integralFrame.size.height / 2);
//	integralFrame = CGRectIntegral(integralFrame);
//	self.frame = integralFrame;
	CGRect theFrame = self.frame;
	CGFloat halfWidth = theFrame.size.width / 2.0f;
	CGFloat halfHeight = theFrame.size.height / 2.0f;
	CGPoint newCenter;
	newCenter.x = roundf(integralCenter.x - halfWidth) + halfWidth;
	newCenter.y = roundf(integralCenter.y - halfHeight) + halfHeight;
	self.center = newCenter;
//SDLog(@"passed in center: %@, new center: %@",NSStringFromCGPoint(integralCenter),NSStringFromCGPoint(self.center));
//SDLog(@"new frame: %@",NSStringFromCGRect(self.frame));
}

-(CGPoint)integralCenter
{
	CGRect integralFrame = self.frame;
	integralFrame.origin = self.center;
	integralFrame = CGRectIntegral(integralFrame);
	return integralFrame.origin;
}

- (void)setIntegralFrame:(CGRect)viewFrame
{
	self.frame = CGRectIntegral(viewFrame);
}

- (CGRect)integralFrame
{
	return CGRectIntegral(self.frame);
}

@end
