//
//  SDPullNavigationManager.m
//  walmart
//
//  Created by Steven Woolgar on 12/05/2013.
//  Copyright (c) 2013 Walmart. All rights reserved.
//

#import "SDPullNavigationManager.h"

#import "NSObject+SDExtensions.h"
#import "SDPullNavigationBarView.h"

static Class sPullNavigationBarViewClass = Nil;
static NSString* sPullNavigationStoryboardId = Nil;

@implementation SDPullNavigationManager

+ (void)initialize
{
    if([self class] == [SDPullNavigationManager class])
    {
        sPullNavigationBarViewClass = [SDPullNavigationBarView class];
    }
}

+ (void)setPullNavigationBarViewClass:(Class)overrideClass
{
    sPullNavigationBarViewClass = overrideClass;
}

+ (NSString*)globalMenuStoryboardId
{
    return sPullNavigationStoryboardId;
}

+ (void)setGlobalMenuStoryboardId:(NSString*)storyboardId
{
    sPullNavigationStoryboardId = [storyboardId copy];
}

+ (instancetype)sharedInstance
{
    static SDPullNavigationManager* sPullNavigationManager = nil;
    static dispatch_once_t sOnceToken;

    dispatch_once( &sOnceToken, ^
    {
        sPullNavigationManager = [[[self class] alloc] init];
    });

    return sPullNavigationManager;
}

// Create the views that we will be forcing into every single viewController's navigationItem.

- (instancetype)init
{
    self = [super init];
    if(self != nil)
    {
        _leftBarItemsView = [[sPullNavigationBarViewClass alloc] initWithEdge:UIRectEdgeLeft];
        _leftBarItemsView.owningBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_leftBarItemsView];
        _rightBarItemsView = [[sPullNavigationBarViewClass alloc] initWithEdge:UIRectEdgeRight];
        _rightBarItemsView.owningBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_rightBarItemsView];

        _showGlobalNavControls = YES;

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(statusBarDidChangeRotationNotification:)
                                                     name:UIApplicationDidChangeStatusBarOrientationNotification
                                                   object:nil];
    }

    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// Called when the navigation controller shows a new top view controller via a push, pop or setting of the view controller stack.
// This is a great time to nerf what the viewController navigationItem will be displaying in the navigationBar.

- (void)navigationController:(UINavigationController*)navigationController
      willShowViewController:(UIViewController*)viewController
                    animated:(BOOL)animated
{
    viewController.navigationItem.leftItemsSupplementBackButton = YES;

    if(self.showGlobalNavControls)
    {
        if(viewController.navigationItem.leftBarButtonItems)
        {
            viewController.navigationItem.leftBarButtonItems = nil;
        }
        if(viewController.navigationItem.leftBarButtonItems == nil)
        {
            [self.leftBarItemsView removeFromSuperview];
            viewController.navigationItem.leftBarButtonItems = @[self.leftBarItemsView.owningBarButtonItem];
        }

        if(viewController.navigationItem.rightBarButtonItems)
        {
            viewController.navigationItem.rightBarButtonItems = nil;
        }
        if(viewController.navigationItem.rightBarButtonItems == nil)
        {
            [self.rightBarItemsView removeFromSuperview];
            viewController.navigationItem.rightBarButtonItems = @[self.rightBarItemsView.owningBarButtonItem];
        }
    }
}

- (void)navigationController:(UINavigationController*)navigationController
       didShowViewController:(UIViewController*)viewController
                    animated:(BOOL)animated
{
    SDLog(@"navigationController:didShowViewController:animated:");
    SDLog(@"   viewController = %@", viewController);
}

- (void)statusBarDidChangeRotationNotification:(NSNotification*)notification
{
    // TODO: We will need to update the size of the left and right global nav controls areas.
}

@end

#pragma mark - Swizzling of UIViewController's UINavigationItem

// This is NOT something I've done lightly. Please talk to Woolie or DrSneed before considering changing.

@implementation UIViewController(SDOverrideOfNavigationItem)

+ (void)load
{
    static dispatch_once_t sOnceToken;
    dispatch_once( &sOnceToken, ^
    {
        [[self class] swizzleMethod:@selector(navigationItem) withMethod:@selector(pullNavigationItem) error:nil];
    });
}

- (UINavigationItem*)pullNavigationItem
{
    UINavigationItem* item = [self pullNavigationItem];
    [item setBackBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@""
                                                                style:UIBarButtonItemStyleBordered
                                                               target:self
                                                               action:@selector(sdBackAction:)]];
    return item;
}

- (void)sdBackAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
