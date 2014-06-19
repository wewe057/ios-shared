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
@property (nonatomic, assign, readonly) CGFloat pullNavigationMenuWidth;                // Defaults to 320.0f

// If you implement the two following calls, pullnav will allow different widths per orientation and overrides the single width one.
@property (nonatomic, assign, readonly) CGFloat pullNavigationMenuWidthForPortrait;     // Defaults to 320.0f
@property (nonatomic, assign, readonly) CGFloat pullNavigationMenuWidthForLandscape;    // Defaults to 320.0f

@property (nonatomic, assign, readonly) Class pullNavigationMenuBackgroundViewClass; // for when you want to extend under the footer adornment

@property (nonatomic, assign, readonly) UIColor *pullNavigationLightboxEffectColor;

- (void)pullNavMenuWillAppear;
- (void)pullNavMenuDidAppear;

- (void)pullNavMenuWillDisappear;
- (void)pullNavMenuDidDisappear;

@end

@interface SDPullNavigationBar : UINavigationBar

@property (nonatomic, strong) IBOutlet UITableViewController<SDPullNavigationBarDelegate>* menuController;

+ (void)setupDefaults;
+ (UINavigationController*)navControllerWithViewController:(UIViewController*)viewController;

- (IBAction)tapAction:(id)sender;
- (void)dismissPullMenuWithCompletionBlock:(void (^)(void))completion;

@end
