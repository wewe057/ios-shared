//
//  SDPullNavigationBar.h
//  walmart
//
//  Created by Brandon Sneed on 08/06/2013.
//  Copyright (c) 2013 Walmart. All rights reserved.
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
@property (nonatomic, weak) SDPullNavigationBar* pullNavigationBarDelegate;
@end

@interface SDPullNavigationBar : UINavigationBar

@property (nonatomic, strong) IBOutlet UITableViewController<SDPullNavigationBarDelegate>* menuController;

+ (void)setupDefaults;
+ (UINavigationController*)navControllerWithViewController:(UIViewController*)viewController;

- (IBAction)tapAction:(id)sender;
- (void)dismissPullMenuWithCompletionBlock:(void (^)(void))completion;

@end
