//
//  SDButton.m
//  walmart
//
//  Created by Peter Marks on 1/20/14.
//  Copyright (c) 2014 Walmart. All rights reserved.
//

#import "SDButton.h"

@implementation SDButton

- (void)drawRect:(CGRect)rect
{
    if ([UIDevice systemMajorVersion] < 7.0)
    {
        // don't do shit.
    }
    else
    {
        [super drawRect:rect];
    }
}

@end
