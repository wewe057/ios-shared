//
//  UIResponder+SDExtensions.m
//  SetDirection
//
//  Created by Steven Woolgar on 02/01/2014.
//  Copyright 2014 SetDirection. All rights reserved.
//
//  Based upon code by http://stackoverflow.com/users/1361982/vjk user.

#import "UIResponder+SDExtensions.h"
#import <objc/message.h>

static char const* const kSDFirstResponderKey = "first-responder";

@implementation UIResponder(SDExtensions)

/**
 Find the current first responder.
 */

- (instancetype)currentFirstResponder
{
    [[UIApplication sharedApplication] sendAction:@selector(findFirstResponder:) to:nil from:self forEvent:nil];
    id obj = objc_getAssociatedObject(self, kSDFirstResponderKey);
    objc_setAssociatedObject(self, kSDFirstResponderKey, nil, OBJC_ASSOCIATION_ASSIGN);

    return obj;
}

- (void)setCurrentFirstResponder:(id)responder
{
    objc_setAssociatedObject(self, kSDFirstResponderKey, responder, OBJC_ASSOCIATION_ASSIGN);
}

- (void)findFirstResponder:(id)sender
{
    [sender setCurrentFirstResponder:self];
}

@end
