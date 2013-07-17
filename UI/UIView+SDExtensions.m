//
//  UIView+SDExtensions.m
//  walmart
//
//  Created by Sam Grover on 2/27/11.
//  Copyright 2011 Set Direction. All rights reserved.
//

#import "UIView+SDExtensions.h"
#import "UIDevice+machine.h"

@interface UIView()
- (UIView *) snapshotView;
- (void) drawViewHierarchyInRect: (CGRect) rect;
@end

@implementation UIView (SDExtensions)

- (void)positionBelowView:(UIView *)argView offset:(CGFloat)argOffset
{
	self.frame = CGRectMake(self.frame.origin.x,
							argView.frame.origin.y + argView.frame.size.height + argOffset,
							self.frame.size.width,
							self.frame.size.height);
}

- (void)setFrameOriginY:(CGFloat)newY
{
	CGRect f = self.frame;
	f.origin.y = newY;
	self.frame = f;
}

- (void)setFrameOriginX:(CGFloat)newX
{
	CGRect f = self.frame;
	f.origin.x = newX;
	self.frame = f;
}

- (void)setIntegralCenter:(CGPoint)integralCenter
{
    self.center = integralCenter;
    self.frame = CGRectIntegral(self.frame);
}

- (CGPoint)integralCenter
{
	CGRect integralFrame = CGRectIntegral(self.frame);
    CGPoint centerPoint = CGPointMake(integralFrame.size.width / 2, integralFrame.size.height / 2);
	return centerPoint;
}

- (void)setIntegralFrame:(CGRect)viewFrame
{
	self.frame = CGRectIntegral(viewFrame);
}

- (CGRect)integralFrame
{
	return CGRectIntegral(self.frame);
}

- (id)firstSubviewOfClass:(Class)aViewClass
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

- (UIView *)snapshot
{
#if __IPHONE_OS_VERSION_MIN_REQUIRED > __IPHONE_6_1
    // if we're on ios7, use the system's snapshoView.
    if ([UIDevice bcdSystemVersion] >= 0x070000 && [self respondsToSelector:@selector(snapshotView)])
        return [self snapshotView];
#endif

    // otherwise, we're doing backwards compatibility to 6.
    UIView *view = [[UIView alloc] initWithFrame:self.frame];
    view.layer.contents = (id)[self screenshot].CGImage;
    return view;
}

- (UIImage *)screenshot
{
    CGFloat currentScale = [UIScreen mainScreen].scale;
    UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, currentScale);

    UIImage *result = nil;

    CGContextRef context = UIGraphicsGetCurrentContext();
    if (context)
    {
        // renderInContext renders in the coordinate space of the layer.

        // apply the layer's geometry to the graphics context
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, self.center.x, self.center.y);
        CGContextConcatCTM(context, self.transform);
        CGContextTranslateCTM(context, -self.bounds.size.width * self.layer.anchorPoint.x, -self.bounds.size.height * self.layer.anchorPoint.y);

        // Render the layer hierarchy to the current context

#if __IPHONE_OS_VERSION_MIN_REQUIRED > __IPHONE_6_1
        // if we're on iOS 7, use the fast, system version.
        if ([UIDevice bcdSystemVersion] >= 0x070000 && [self respondsToSelector:@selector(drawViewHierarchyInRect:)])
            [self drawViewHierarchyInRect:self.frame];
        else
#endif
            [self.layer renderInContext:context];

        // Restore the context
        CGContextRestoreGState(context);

        result = UIGraphicsGetImageFromCurrentImageContext();
    }
    else
        SDLog(@"Attempting to capture a screenshot of view without a graphics context!");

    return result;
}

@end
