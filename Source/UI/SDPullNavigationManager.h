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

@property (nonatomic, strong) Class pullNavigationBarViewClass;
@property (nonatomic, strong) UIImage* menuAdornmentImage;
@property (nonatomic, copy) NSString* globalMenuStoryboardId;
@property (nonatomic, weak) id<SDPullNavigationSetupProtocol> delegate;
@property (nonatomic, strong) SDContainerViewController* globalPullNavController;
@property (nonatomic, assign) BOOL showGlobalNavControls;   // Turn this off and I won't take away your navigationItems
@property (nonatomic, strong) SDPullNavigationBarControlsView* leftBarItemsView;
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
