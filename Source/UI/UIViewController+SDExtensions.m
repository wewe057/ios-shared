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
    return [self loadFromStoryboardNamed:nil];
}

+ (instancetype)loadFromStoryboardNamed:(NSString *)storyboardName
{
    NSString *modifiedName = [storyboardName copy];
    NSString *className = [self className];
    NSString *resourcePath = nil;
    UIViewController *result = nil;
    BOOL usingClassName = NO;
    
    // they passed in nil, assume the storyboardName should be the class name.
    if (!modifiedName)
    {
        modifiedName = className;
        usingClassName = YES;
    }

    // Search for: storyboardName.storyboardc / className.storyboardc
    resourcePath = [[NSBundle bundleForClass:[self class]] pathForResource:modifiedName ofType:@"storyboardc"];

    // Search for: storyboardName_iPhone.storyboardc / className_iPhone.storyboardc
    if (!resourcePath)
    {
        modifiedName = [NSString stringWithFormat:@"%@_%@", modifiedName, [UIDevice iPad] ? @"iPad" : @"iPhone"];
        resourcePath = [[NSBundle bundleForClass:[self class]] pathForResource:modifiedName ofType:@"storyboardc"];
    }

    if (!usingClassName && !resourcePath) // prevents duplicate searches.
    {
        // Search for: className.storyboardc
        if (!resourcePath)
        {
            modifiedName = className;
            resourcePath = [[NSBundle bundleForClass:[self class]] pathForResource:modifiedName ofType:@"storyboardc"];
        }

        // Search for: className_iPhone.storyboardc
        if (!resourcePath)
        {
            modifiedName = [NSString stringWithFormat:@"%@_%@", className, [UIDevice iPad] ? @"iPad" : @"iPhone"];
            resourcePath = [[NSBundle bundleForClass:[self class]] pathForResource:modifiedName ofType:@"storyboardc"];
        }
    }
    
    // if so, load that motherfucker.
    if (resourcePath)
    {
        // this will throw an exception if it can't find the storyboard.
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:modifiedName bundle:[NSBundle bundleForClass:[self class]]];
        result = [storyboard instantiateInitialViewController];
    }
    // else we're kind of SOL.  the caller had better support getting a nil view controller.

    if ([result isKindOfClass:[self class]])
        [result view];
    else
        result = nil;
    
    // try the identifier...
    if (!result)
        result = [self loadFromStoryboardNamed:storyboardName identifier:[self className]];

    // the types didn't match.  best to return nil.
    return result;
}

+ (instancetype)loadFromStoryboardNamed:(NSString *)storyboardName identifier:(NSString *)identifier
{
    // if no identifier was given, use the class name.
    if (!identifier)
        identifier = [self className];
    
    NSString *modifiedName = [storyboardName copy];
    NSString *className = [self className];
    NSString *resourcePath = nil;
    UIViewController *result = nil;
    BOOL usingClassName = NO;
    
    // they passed in nil, assume the storyboardName should be the class name.
    if (!modifiedName)
    {
        modifiedName = className;
        usingClassName = YES;
    }
    
    // Search for: storyboardName.storyboardc / className.storyboardc
    resourcePath = [[NSBundle bundleForClass:[self class]] pathForResource:modifiedName ofType:@"storyboardc"];
    
    // Search for: storyboardName_iPhone.storyboardc / className_iPhone.storyboardc
    if (!resourcePath)
    {
        modifiedName = [NSString stringWithFormat:@"%@_%@", modifiedName, [UIDevice iPad] ? @"iPad" : @"iPhone"];
        resourcePath = [[NSBundle bundleForClass:[self class]] pathForResource:modifiedName ofType:@"storyboardc"];
    }
    
    if (!usingClassName && !resourcePath) // prevents duplicate searches.
    {
        // Search for: className.storyboardc
        if (!resourcePath)
        {
            modifiedName = className;
            resourcePath = [[NSBundle bundleForClass:[self class]] pathForResource:modifiedName ofType:@"storyboardc"];
        }
        
        // Search for: className_iPhone.storyboardc
        if (!resourcePath)
        {
            modifiedName = [NSString stringWithFormat:@"%@_%@", className, [UIDevice iPad] ? @"iPad" : @"iPhone"];
            resourcePath = [[NSBundle bundleForClass:[self class]] pathForResource:modifiedName ofType:@"storyboardc"];
        }
    }
    
    // if so, load that motherfucker.
    if (resourcePath)
    {
        // this will throw an exception if it can't find the storyboard.
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:modifiedName bundle:[NSBundle bundleForClass:[self class]]];
        result = [storyboard instantiateViewControllerWithIdentifier:identifier];
    }
    // else we're kind of SOL.  the caller had better support getting a nil view controller.
    
    if ([result isKindOfClass:[self class]])
        [result view];
    else
        result = nil;

    // the types didn't match.  best to return nil.
    return result;
}

@end
