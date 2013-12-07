//
//  SDPullNavigationManager.h
//  walmart
//
//  Created by Steven Woolgar on 12/05/2013.
//  Copyright (c) 2013 Walmart. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SDPullNavigationBarView;

@interface SDPullNavigationManager : NSObject<UINavigationControllerDelegate>

+ (instancetype)sharedInstance;
+ (void)setPullNavigationBarViewClass:(Class)overrideClass;
+ (NSString*)globalMenuStoryboardId;
+ (void)setGlobalMenuStoryboardId:(NSString*)storyboardId;

@property (nonatomic, assign) BOOL showGlobalNavControls;   // Turn this off and I won't take away your navigationItems
@property (nonatomic, strong) SDPullNavigationBarView* leftBarItemsView;
@property (nonatomic, strong) SDPullNavigationBarView* rightBarItemsView;

@end
