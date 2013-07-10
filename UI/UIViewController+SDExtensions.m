//
//  UIViewController+SDExtensions.m
//  Photos
//
//  Created by Brandon Sneed on 5/16/13.
//  Copyright (c) 2013 walmart. All rights reserved.
//

#import "UIViewController+SDExtensions.h"

@implementation UIViewController (SDExtensions)

+ (id)instanceInNavigationController;
{
    id instance = [[self alloc] initWithNibName:nil bundle:nil];
    return [[UINavigationController alloc] initWithRootViewController:instance];
}

+ (id)instanceInNavigationControllerWithNibName:(NSString *)nibName bundle:(NSBundle *)bundle
{
    id instance = [[self alloc] initWithNibName:nibName bundle:bundle];
    return [[UINavigationController alloc] initWithRootViewController:instance];
}

- (UINavigationController *)wrapInstanceInNavigationController
{
    return [[UINavigationController alloc] initWithRootViewController:self];
}

@end
