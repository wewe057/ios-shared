//
//  SDPullNavigationBarView.m
//  walmart
//
//  Created by Steven Woolgar on 12/05/2013.
//  Copyright (c) 2013 Walmart. All rights reserved.
//

#import "SDPullNavigationBarView.h"

@implementation SDPullNavigationBarView

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

@end
