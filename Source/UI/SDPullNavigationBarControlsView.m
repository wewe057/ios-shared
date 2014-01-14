//
//  SDPullNavigationBarControlsView.m
//  walmart
//
//  This is a simple list of controls that live in the pullnav.
//
//  Created by Steven Woolgar on 12/06/2013.
//  Copyright (c) 2013 Walmart. All rights reserved.
//

#import "SDPullNavigationBarControlsView.h"

@implementation SDPullNavigationBarControlsView

- (instancetype)initWithEdge:(UIRectEdge)edge
{
    NSAssert(edge == UIRectEdgeLeft || edge == UIRectEdgeRight, @"Only left or right edges are supported.");
    
    self = [super initWithFrame:(CGRect){CGPointZero, { 200.0f, 40.0f }}];
    if( self != nil )
    {
        self.backgroundColor = [UIColor clearColor];
        _edge = edge;
    }
    
    return self;
}

- (void)layoutWithBarItems:(NSArray *)barItems
{
    self.barItems = barItems;

    NSArray* subviews = [self.subviews copy];
    for(UIControl* subview in subviews)
        [subview removeFromSuperview];

    [self setNeedsLayout];
}

// Layout from left to right for the edge == UIRectEdgeLeft and from right to left for the edge == UIRectEdgeRight

- (void)layoutSubviews
{
    CGFloat currentX = self.edge == UIRectEdgeLeft ? 0.0f : self.size.width;
    for(UIControl* control in self.barItems)
    {
        if(self.edge == UIRectEdgeRight)
            currentX -= control.size.width;

        control.frame = (CGRect){{ currentX, self.size.height * 0.5f - control.size.height * 0.5f }, control.size };
        [self addSubview:control];

        if(self.edge == UIRectEdgeLeft)
            currentX += control.size.width;
    }
}

#pragma mark - BarItems API

- (void)addBarItem:(UIView*)view
{
    if(self.barItems == nil)
        self.barItems = [NSArray arrayWithObject:view];
    else
        self.barItems = [self.barItems arrayByAddingObject:view];
    [self layoutWithBarItems:self.barItems];
}

- (void)addBarItemSpacerWithWidth:(CGFloat)spacerWidth
{
    UIView* spacer = [[UIView alloc] initWithFrame:(CGRect){ CGPointZero, { spacerWidth, 2.0f }}];

    if(self.barItems == nil)
        self.barItems = [NSArray arrayWithObject:spacer];
    else
        self.barItems = [self.barItems arrayByAddingObject:spacer];

    [self layoutWithBarItems:self.barItems];
}

@end
