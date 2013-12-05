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

+ (instancetype)loadFromStoryboard
{
    return [self loadFromStoryboard:nil];
}

+ (instancetype)loadFromStoryboard:(NSString *)storyboardName
{
    NSString *modifiedName = [storyboardName copy];
    NSString *originalName = [storyboardName copy];
    UIViewController *result = nil;

    if (!modifiedName)
    {
        NSString *className = [self className];
        modifiedName = [NSString stringWithFormat:@"%@_%@", className, [UIDevice iPad] ? @"iPad" : @"iPhone"];
    }

    NSString *resourcePath = [[NSBundle bundleForClass:[self class]] pathForResource:modifiedName ofType:@"storyboardc"];
    if (!resourcePath)
        modifiedName = [NSString stringWithFormat:@"%@_%@", originalName, [UIDevice iPad] ? @"iPad" : @"iPhone"];

    // this will throw an exception if it can't find the storyboard.
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:modifiedName bundle:[NSBundle bundleForClass:[self class]]];
    result = [storyboard instantiateInitialViewController];

    if ([result isKindOfClass:[self class]])
        [result view];
    else
        result = nil;
    
    // try the identifier...
    if (!result)
        result = [self loadFromStoryboard:storyboardName identifier:[self className]];

    // the types didn't match.  best to return nil.
    return result;
}

+ (instancetype)loadFromStoryboard:(NSString *)storyboardName identifier:(NSString *)identifier
{
    NSString *modifiedName = [storyboardName copy];
    NSString *originalName = [storyboardName copy];
    UIViewController *result = nil;

    if (!modifiedName)
    {
        NSString *className = [self className];
        modifiedName = [NSString stringWithFormat:@"%@_%@", className, [UIDevice iPad] ? @"iPad" : @"iPhone"];
    }

    NSString *resourcePath = [[NSBundle bundleForClass:[self class]] pathForResource:modifiedName ofType:@"storyboardc"];
    if (!resourcePath)
        modifiedName = [NSString stringWithFormat:@"%@_%@", originalName, [UIDevice iPad] ? @"iPad" : @"iPhone"];

    if (!identifier)
        identifier = [self className];
    
    // this will throw an exception if it can't find the storyboard.
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:modifiedName bundle:[NSBundle bundleForClass:[self class]]];
    result = [storyboard instantiateViewControllerWithIdentifier:identifier];

    if ([result isKindOfClass:[self class]])
        [result view];
    else
        result = nil;

    // the types didn't match.  best to return nil.
    return result;
}

@end
