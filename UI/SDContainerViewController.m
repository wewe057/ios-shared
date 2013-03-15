//
//  SDContainerViewController.m
//
//  Created by Brandon Sneed on 1/17/13.
//  Copyright (c) 2013 SetDirection. All rights reserved.
//

#import "SDContainerViewController.h"

@implementation SDContainerViewController

- (id)init
{
    self = [super initWithNibName:nil bundle:nil];
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)loadView
{
    [super loadView];
    
    self.view.autoresizesSubviews = YES;
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    if (!_containerView)
        _containerView = self.view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.selectedViewController = _selectedViewController;
}

#pragma mark properties

- (void)setViewControllers:(NSArray *)viewControllers
{
    if (_viewControllers == viewControllers)
        return;

    // this will remove any current controller.
    if (_selectedViewController)
        self.selectedViewController = nil;
    
    _viewControllers = viewControllers;
    self.selectedViewController = [viewControllers objectAtIndex:0];
}

- (void)setSelectedIndex:(NSUInteger)index
{
    if (index < _viewControllers.count)
        self.selectedViewController = [_viewControllers objectAtIndex:index];
}

- (NSUInteger)selectedIndex
{
    return [_viewControllers indexOfObject:self.selectedViewController];
}

- (void)setSelectedViewController:(UIViewController *)selectedViewController
{
    NSUInteger index = [_viewControllers indexOfObject:selectedViewController];
    if (index == NSNotFound)
        return;
    
    // remove the existing one from the parent controller
    UIViewController *currentController = _selectedViewController;
    [currentController removeFromParentViewController];
    [currentController.view removeFromSuperview];
    [currentController didMoveToParentViewController:nil];
    
    _selectedViewController = selectedViewController;
    
    // add the new one to the parent controller
    [self addChildViewController:_selectedViewController];
    _selectedViewController.view.frame = self.containerView.bounds;
    [self.containerView addSubview:_selectedViewController.view];
    [_selectedViewController didMoveToParentViewController:self];
}

@end
