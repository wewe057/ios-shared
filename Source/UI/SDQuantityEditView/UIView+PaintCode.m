//
//  UIView+PaintCode.m
//
//  Created by ricky cancro on 12/24/13.
//  Copyright (c) 2013 SetDirection. All rights reserved.
//

#import "UIView+PaintCode.h"

@implementation UIView(PaintCode)

- (UIImage*)imageForSelector:(SEL)selector
{
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0f);
	
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [self performSelector:selector];
#pragma clang diagnostic pop
	
    UIImage* result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return result;
}

@end
