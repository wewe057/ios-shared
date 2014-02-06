//
//  SDMultilineLabel.m
//  LayoutTests
//
//  Created by Steve Riggins on 1/24/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import "SDMultilineLabel.h"

@implementation SDMultilineLabel

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Not happy with self. here
        self.numberOfLines = 0;
    }
    return self;
}

// This allows the label to layout properly with auto layout
- (void)layoutSubviews
{
    self.preferredMaxLayoutWidth = self.frame.size.width;
    [super layoutSubviews];
}
@end
