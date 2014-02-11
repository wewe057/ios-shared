//
//  SDPullNavigationBar.h
//  ios-shared
//
//  Created by Brandon Sneed on 08/06/2013.
//  Copyright 2013-2014 SetDirection. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SDContainerViewController.h"

@class SDPullNavigationBar;

@protocol SDPullNavigationSetupProtocol <NSObject, UITabBarControllerDelegate>
@required
- (void)setupNavigationBar;
- (void)setupNavigationBarItems;
- (SDContainerViewController*)setupGlobalContainerViewController;
@end

@protocol SDPullNavigationBarDelegate <NSObject>
@required
@property (nonatomic, weak) SDPullNavigationBar* pullNavigationBarDelegate;
@property (nonatomic, assign, readonly) CGFloat pullNavigationMenuHeight;

@optional
@property (nonatomic, assign, readonly) CGFloat pullNavigationMenuWidth;    // Defaults to 320.0f
@end

@interface SDPullNavigationBar : UINavigationBar

@property (nonatomic, strong) IBOutlet UITableViewController<SDPullNavigationBarDelegate>* menuController;

+ (void)setupDefaults;
+ (UINavigationController*)navControllerWithViewController:(UIViewController*)viewController;

- (IBAction)tapAction:(id)sender;
- (void)dismissPullMenuWithCompletionBlock:(void (^)(void))completion;

@end
