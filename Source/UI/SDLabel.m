//
//  SDLabel.m
//  SetDirection
//
//  Created by Sam Grover on 3/5/11.
//  Copyright 2011 SetDirection. All rights reserved.
//

#import "SDLabel.h"


@implementation SDLabel


- (CGFloat)textHeight
{
    if (self.text == nil)
        return 0;
    
	CGSize theSize = [self.text sizeWithFont:self.font
						   constrainedToSize:CGSizeMake(self.frame.size.width, INFINITY)
							   lineBreakMode:self.lineBreakMode];
	return theSize.height;
}

- (void)setText:(NSString *)argText
{
	[super setText:argText];
	CGFloat height = [self textHeight];
	CGRect theFrame = self.frame;
	theFrame.size.height = height;
	self.frame = theFrame;
}

- (CGSize)sizeThatFits:(CGSize)size
{
	size.height = [self textHeight];
	return size;
}

@end
