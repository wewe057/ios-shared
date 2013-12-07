//
//  SDPullNavigationBarTabButton.m
//  walmart
//
//  Created by Brandon Sneed on 11/06/2013.
//  Copyright (c) 2013 Walmart. All rights reserved.
//

#import "SDPullNavigationBarTabButton.h"

#import "SDPullNavigationBar.h"

@interface SDPullNavigationBarTabButton()
@property (nonatomic, strong) UITapGestureRecognizer* tapGesture;
@end

@implementation SDPullNavigationBarTabButton

- (id)initWithNavigationBar:(SDPullNavigationBar*)navigationBar
{
    self = [super initWithFrame:CGRectZero];
    if(self != nil)
    {
        self.frame = (CGRect){ self.frame.origin, { 53.0f, 55.0f } };
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:navigationBar action:@selector(tapAction:)];
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        [self addGestureRecognizer:_tapGesture];
    }

    return self;
}

- (void)drawRect:(CGRect)rect
{
    if(!self.tuckedTab)
    {
        //// General Declarations
        CGContextRef context = UIGraphicsGetCurrentContext();

        //// Color Declarations
        UIColor* backgroundColor = [UIColor colorWithRed: 0.114 green: 0.416 blue: 0.651 alpha: 1];
        UIColor* backgroundShadowColor = [UIColor colorWithRed: 0.376 green: 0.376 blue: 0.376 alpha: 1];

        //// Shadow Declarations
        UIColor* backgroundShadow = [[UIColor blackColor] colorWithAlphaComponent: 0.25];
        CGSize backgroundShadowOffset = CGSizeMake(0.1, 1.1);
        CGFloat backgroundShadowBlurRadius = 1;
        UIColor* dotShadow = backgroundShadowColor;
        CGSize dotShadowOffset = CGSizeMake(0.1, 1.1);
        CGFloat dotShadowBlurRadius = 0;

        //// Group
        {
            //// tabBezier Drawing
            UIBezierPath* tabBezierPath = [UIBezierPath bezierPath];
            [tabBezierPath moveToPoint: CGPointMake(10.95, 53)];
            [tabBezierPath addLineToPoint: CGPointMake(42.05, 53)];
            [tabBezierPath addLineToPoint: CGPointMake(44.24, 52.26)];
            [tabBezierPath addLineToPoint: CGPointMake(46.43, 51.16)];
            [tabBezierPath addLineToPoint: CGPointMake(53, 46)];
            [tabBezierPath addLineToPoint: CGPointMake(0, 46)];
            [tabBezierPath addLineToPoint: CGPointMake(6.57, 51.16)];
            [tabBezierPath addLineToPoint: CGPointMake(8.76, 52.26)];
            [tabBezierPath addLineToPoint: CGPointMake(10.95, 53)];
            [tabBezierPath closePath];
            CGContextSaveGState(context);
            CGContextSetShadowWithColor(context, backgroundShadowOffset, backgroundShadowBlurRadius, backgroundShadow.CGColor);
            [backgroundColor setFill];
            [tabBezierPath fill];
            CGContextRestoreGState(context);

            //// dot1Rectangle Drawing
            UIBezierPath* dot1RectanglePath = [UIBezierPath bezierPathWithRect: CGRectMake(20, 48, 2, 2)];
            CGContextSaveGState(context);
            CGContextSetShadowWithColor(context, dotShadowOffset, dotShadowBlurRadius, dotShadow.CGColor);
            [[UIColor whiteColor] setFill];
            [dot1RectanglePath fill];
            CGContextRestoreGState(context);

            //// dot2Rectangle Drawing
            UIBezierPath* dot2RectanglePath = [UIBezierPath bezierPathWithRect: CGRectMake(25, 48, 2, 2)];
            CGContextSaveGState(context);
            CGContextSetShadowWithColor(context, dotShadowOffset, dotShadowBlurRadius, dotShadow.CGColor);
            [[UIColor whiteColor] setFill];
            [dot2RectanglePath fill];
            CGContextRestoreGState(context);

            //// dot3Rectangle Drawing
            UIBezierPath* dot3RectanglePath = [UIBezierPath bezierPathWithRect: CGRectMake(30, 48, 2, 2)];
            CGContextSaveGState(context);
            CGContextSetShadowWithColor(context, dotShadowOffset, dotShadowBlurRadius, dotShadow.CGColor);
            [[UIColor whiteColor] setFill];
            [dot3RectanglePath fill];
            CGContextRestoreGState(context);
        }
    }
}

@end
