//
//  SDContainerViewController.h
//
//  Created by Brandon Sneed on 1/17/13.
//  Copyright (c) 2013 SetDirection. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 SDContainerViewController is effectively a UITabBarController without a tab bar.
 */

@interface SDContainerViewController : UIViewController

/**
 Returns the selected view controller or sets it. read/write.
 */
@property (nonatomic, assign) UIViewController *selectedViewController;
/**
 Index of the selected view controller.  read/write.
 */
@property (nonatomic, assign) NSUInteger selectedIndex;
/**
 The array of view controllers to be used.
 */
@property (nonatomic, copy) NSArray *viewControllers;
/**
 The container that this controller will be a subview of.  The default is self.view.
 */
@property (nonatomic, strong) IBOutlet UIView *containerView; // defaults to self.view

@end
