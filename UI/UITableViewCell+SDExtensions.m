//
//  UITableViewCell+SDExtensions.m
//  walmart
//
//  Created by brandon on 3/16/11.
//  Copyright 2011 Set Direction. All rights reserved.
//

#import "UITableViewCell+SDExtensions.h"
#import <objc/runtime.h>

static NSString *kUITableViewCellUserInfoString = @"kUITableViewUserInfoString";

@implementation UITableViewCell(SDExtensions)

@dynamic userInfo;

- (id)userInfo
{
    return objc_getAssociatedObject(self, kUITableViewCellUserInfoString);
}

- (void)setUserInfo:(id)value
{
    objc_setAssociatedObject(self, kUITableViewCellUserInfoString, value, OBJC_ASSOCIATION_RETAIN);
}

- (void)dealloc
{
    [self setUserInfo:nil];
    [super dealloc];
}

@end
