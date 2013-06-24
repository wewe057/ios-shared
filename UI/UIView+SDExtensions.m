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
    self.y = newY;
}

-(void)setFrameOriginX:(CGFloat)newX
{
    self.x = newX;
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

-(id)firstSubviewOfClass:(Class)aViewClass
{
	NSArray *subs = [self subviews];
	id aView = nil;
	
	NSEnumerator *e = [subs objectEnumerator];
	while((aView = [e nextObject]))
	{
		if([aView isKindOfClass: aViewClass])
		{
			return aView;
		}
	}
	
	return nil;
}

- (void)setX:(CGFloat)x
{
    CGRect f = self.frame;
    f.origin.x = x;
    self.frame = f;
}

- (void)setY:(CGFloat)y
{
    CGRect f = self.frame;
    f.origin.y = y;
    self.frame = f;
}

- (void)setWidth:(CGFloat)width
{
    CGRect f = self.frame;
    f.size.width = width;
    self.frame = f;
}

- (void)setHeight:(CGFloat)height;
{
    CGRect f = self.frame;
    f.size.height = height;
    self.frame = f;
}

- (void)setOrigin:(CGPoint)origin
{
    CGRect f = self.frame;
    f.origin = origin;
    self.frame = f;
}

- (void)setSize:(CGSize)size;
{
    CGRect f = self.frame;
    f.size = size;
    self.frame = f;
}


- (CGFloat)x
{
    return self.frame.origin.x;
}

- (CGFloat)y;
{
    return self.frame.origin.y;
}

- (CGFloat)width
{
    return self.frame.size.width;
}

- (CGFloat)height
{
    return self.frame.size.height;
}

- (CGPoint)origin
{
    return self.frame.origin;
}

- (CGSize)size
{
    return self.frame.size;
}

@end
