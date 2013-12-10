//
//  SDPullNavigationBar.h
//  walmart
//
//  Created by Brandon Sneed on 08/06/2013.
//  Copyright (c) 2013 Walmart. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SDPullNavigationBar;

@protocol SDPullNavigationSetupProtocol <NSObject, UITabBarControllerDelegate>
@required
- (void)setupNavigation;
- (void)setupGlobalMenu;
@end

@protocol SDPullNavigationBarDelegate <NSObject>
@property (nonatomic, weak) SDPullNavigationBar* pullNavigationBarDelegate;
@end

@interface SDPullNavigationBar : UINavigationBar

@property (nonatomic, strong) IBOutlet UITableViewController<SDPullNavigationBarDelegate>* menuController;

+ (void)setupDefaults;
+ (void)setMenuAdornmentImage:(UIImage*)image;
+ (UINavigationController*)navControllerWithViewController:(UIViewController*)viewController;

- (IBAction)tapAction:(id)sender;
- (void)dismissPullMenu;

@end
