//
//  SDPullNavigationManager.m
//  ios-shared

//
//  Created by Steven Woolgar on 12/05/2013.
//  Copyright 2013-2014 SetDirection. All rights reserved.
//

#import "SDPullNavigationManager.h"

#import "NSObject+SDExtensions.h"
#import "SDPullNavigationBarControlsView.h"
#import "SDPullNavigationAutomation.h"

@implementation SDPullNavigationManager

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
        _leftBarItemsView = [[[SDPullNavigationBarControlsView class] alloc] initWithEdge:UIRectEdgeLeft];
        _leftBarItemsView.owningBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_leftBarItemsView];
        _rightBarItemsView = [[[SDPullNavigationBarControlsView class] alloc] initWithEdge:UIRectEdgeRight];
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

- (void)setDelegate:(id)delegate
{
    if(delegate)
    {
        [delegate setupNavigationBar];
        [delegate setupNavigationBarItems];
        _globalPullNavController = [delegate setupGlobalContainerViewController];
    }
    else
    {
        _globalPullNavController = nil;
        _delegate = nil;
    }
}

- (void)setPullNavigationBarViewClass:(Class)overrideClass
{
    _leftBarItemsView = [[overrideClass alloc] initWithEdge:UIRectEdgeLeft];
    _leftBarItemsView.owningBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_leftBarItemsView];
    _rightBarItemsView = [[overrideClass alloc] initWithEdge:UIRectEdgeRight];
    _rightBarItemsView.owningBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_rightBarItemsView];
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

#pragma mark - Navigation Helpers:

- (BOOL)navigateToTopLevelController:(Class)topLevelViewControllerClass
{
    UINavigationController* foundNavController = [self.globalPullNavController navigationControllerForViewControllerClass:topLevelViewControllerClass];

    if(foundNavController)
        self.globalPullNavController.selectedViewController = foundNavController;

    return foundNavController != nil;
}

- (void)navigateToTopLevelController:(Class)topLevelViewControllerClass andPopToRootWithAnimation:(BOOL)animate
{
    if([self navigateToTopLevelController:topLevelViewControllerClass])
        [(UINavigationController*)self.globalPullNavController.selectedViewController popToRootViewControllerAnimated:animate];
}

#pragma mark - Navigation Automation

- (void)navigateWithSteps:(NSArray*)steps
{
    NSAssert(steps, @"Not gonna automate a lot with a nil steps array.");
    NSAssert(steps.count, @"Not gonna automate a lot with no steps in the array.");

    NSDictionary* topLevelStep = steps[0];
    id topLevelController = topLevelStep[SDPullNavigationControllerKey];

    NSAssert(topLevelController, @"The first level of automation needs at least a controller.");

    // Determine where this topLevel is. Is it part of the containerViewController
    // or is it to be found in the navigationBarItems?

    // Check to see if we can find the requested toplevel class somewhere in the list of containerViewControllers

    UINavigationController* foundNavigationController = [self topLevelViewController:topLevelController];
    if(foundNavigationController)
    {
        [self navigateTopLevelViewController:foundNavigationController withSteps:steps];
    }
    else
    {
        // We did not find the supplied controller in the list of top level view controllers in the globalPullNavControllers list.
        // Now start looking through the things on the navigation bar.

        UIControl* foundControl = [self barItemController:topLevelController];
        [self navigateBarItem:foundControl withSteps:steps];
    }
}

- (void)navigateTopLevelViewController:(UINavigationController*)navigationController withSteps:(NSArray*)steps
{
}

- (void)navigateBarItem:(UIControl*)control withSteps:(NSArray*)steps
{
    NSDictionary* firstLevelStep = steps[0];

    control.pullNavigationAutomationCommand = firstLevelStep[SDPullNavigationCommandKey];
    control.pullNavigationAutomationData = firstLevelStep[SDPullNavigationDataKey];

    [control sendActionsForControlEvents:UIControlEventTouchUpInside | UIControlEventEditingDidBegin];
}

#pragma mark - Automation Utilities

- (UINavigationController*)topLevelViewController:(id)controller
{
    UINavigationController* foundNavigationController = nil;
    foundNavigationController = [self.globalPullNavController navigationControllerForViewControllerClass:controller];
    if(foundNavigationController == nil)
        foundNavigationController = [self.globalPullNavController navigationControllerForViewController:controller];

    return foundNavigationController;
}

- (UIControl*)barItemController:(id)controller
{
    UIControl* foundControl = nil;

    NSArray* barItems = [self.leftBarItemsView.barItems arrayByAddingObjectsFromArray:self.rightBarItemsView.barItems];
    for(UIView* item in barItems)
    {
        Class pullNavigationAutomationClass = item.pullNavigationAutomationClass;
        if(pullNavigationAutomationClass)
        {
            if(pullNavigationAutomationClass == controller || pullNavigationAutomationClass == [controller class])
            {
                // We found the barItem that we want to automate.

                if([item isKindOfClass:[UIControl class]])
                    foundControl = (UIControl*)item;
                break;
            }
        }
    }

    return foundControl;
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

    if([self.navigationController.navigationBar isKindOfClass: [SDPullNavigationBar class]])
    {
        [item setBackBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@""
                                                                    style:UIBarButtonItemStyleBordered
                                                                   target:self
                                                                   action:@selector(sdBackAction:)]];
    }

    return item;
}

- (void)sdBackAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
