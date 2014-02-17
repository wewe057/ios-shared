//
//  SDPullNavigationManager.h
//  ios-shared

//
//  Created by Steven Woolgar on 12/05/2013.
//  Copyright 2013-2014 SetDirection. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SDPullNavigationBar.h"

@class SDPullNavigationBarControlsView;

@interface SDPullNavigationManager : NSObject<UINavigationControllerDelegate>

/**
 Override to draw the tab button. Defaults to SDPullNavigationBarTabButton.
 @optional
 */

@property (nonatomic, strong) Class pullNavigationBarTabButtonClass;

@property (nonatomic, strong) Class pullNavigationBarViewClass;

/**
 Image that goes on the bottom of the menu to indicate that it is closable.
 @optional
 */

@property (nonatomic, strong) UIImage* menuAdornmentImage;

/**
 This is the offset to make the bottom adornment tuck neatly under the navbar.
 This works if the bottom adornment looks like the top adornment but is slight taller.
 This measurement is the difference in height between the two.
 @optional
 */

@property (nonatomic, assign) CGFloat menuAdornmentImageOverlapHeight;

/**
 The storyboard ID to use for the global menu.
 */

@property (nonatomic, copy) NSString* globalMenuStoryboardId;
@property (nonatomic, weak) id<SDPullNavigationSetupProtocol> delegate;
@property (nonatomic, strong) SDContainerViewController* globalPullNavController;

/**
 Set this on while pushing a new nav. If this is YES then I won't override your nav items with the global ones.
 */

@property (nonatomic, assign) BOOL showGlobalNavControls;   // Turn this off and I won't take away your navigationItems

/**
 Controls to present on the navbar on the left hand side all the time (exception being when you set the showGlobalNavControls == YES).
 Items are added from left to right (towards the middle).
 */

@property (nonatomic, strong) SDPullNavigationBarControlsView* leftBarItemsView;

/**
 Controls to present on the navbar on the right hand side all the time (exception being when you set the showGlobalNavControls == YES).
 Items are added from right to left (towards the middle).
 */

@property (nonatomic, strong) SDPullNavigationBarControlsView* rightBarItemsView;

+ (instancetype)sharedInstance;
- (void)navigateWithSteps:(NSArray*)steps;

/**
 Navigate to one of the top level view controllers defined in the 'globalPullNavController'.
 */
- (BOOL)navigateToTopLevelController:(Class)topLevelViewControllerClass;

/**
 Navigate to one of the top level view controllers defined in the 'globalPullNavController' and pop to the
 root.
 */
- (void)navigateToTopLevelController:(Class)topLevelViewControllerClass andPopToRootWithAnimation:(BOOL)animate;

@end
