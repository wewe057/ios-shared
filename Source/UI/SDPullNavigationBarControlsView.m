//
//  SDPullNavigationBarControlsView.m
//  walmart
//
//  This is a version of the SDPullNavigationBarView that manages simple list of controls for you.
//
//  Created by Steven Woolgar on 12/06/2013.
//  Copyright (c) 2013 Walmart. All rights reserved.
//

#import "SDPullNavigationBarControlsView.h"

@implementation SDPullNavigationBarControlsView

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
