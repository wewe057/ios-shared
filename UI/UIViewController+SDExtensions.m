//
//  UIViewController+SDExtensions.m
//  Photos
//
//  Created by Brandon Sneed on 5/16/13.
//  Copyright (c) 2013 SetDirection. All rights reserved.
//

#import "UIViewController+SDExtensions.h"

@implementation UIViewController (SDExtensions)

+ (UINavigationController *)instanceInNavigationController;
{
    id instance = [[self alloc] initWithNibName:nil bundle:nil];
    return [[UINavigationController alloc] initWithRootViewController:instance];
}

+ (UINavigationController *)instanceInNavigationControllerWithNibName:(NSString *)nibName bundle:(NSBundle *)bundle
{
    id instance = [[self alloc] initWithNibName:nibName bundle:bundle];
    return [[UINavigationController alloc] initWithRootViewController:instance];
}

- (UINavigationController *)wrapInstanceInNavigationController
{
    return [[UINavigationController alloc] initWithRootViewController:self];
}

- (UIViewController *)viewControllerFromStoryboard:(NSString *)storyboardName
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:[NSBundle bundleForClass:[self class]]];
    UIViewController *result = [storyboard instantiateInitialViewController];

    if ([result isKindOfClass:[self class]])
        return result;

    // the types didn't match.  best to return nil.
    return nil;
}

- (UIViewController *)viewControllerFromStoryboard:(NSString *)storyboardName identifier:(NSString *)identifier
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:[NSBundle bundleForClass:[self class]]];
    UIViewController *result = [storyboard instantiateViewControllerWithIdentifier:identifier];

    if ([result isKindOfClass:[self class]])
        return result;

    // the types didn't match.  best to return nil.
    return nil;
}

@end
