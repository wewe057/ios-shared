//
//  SDPullNavigationBarBackground.m
//  walmart
//
//  Created by Brandon Sneed on 11/06/2013.
//  Copyright (c) 2013 Walmart. All rights reserved.
//

#import "SDPullNavigationBarBackground.h"

@implementation SDPullNavigationBarBackground

- (void)setDelegate:(id<SDPullNavigationBarOverlayProtocol>)delegate
{
    if (delegate && [delegate respondsToSelector:@selector(drawOverlayRect:)])
    {
        _delegate = delegate;
        return;
    }

    _delegate = nil;
}

- (void)drawRect:(CGRect)rect
{
    [self.delegate drawOverlayRect:rect];
}

@end
