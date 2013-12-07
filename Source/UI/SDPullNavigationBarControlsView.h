//
//  SDPullNavigationBarControlsView.h
//  walmart
//
//  This is a version of the SDPullNavigationBarView that manages simple list of controls for you.
//
//  Created by Steven Woolgar on 12/06/2013.
//  Copyright (c) 2013 Walmart. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SDPullNavigationBarView.h"

@interface SDPullNavigationBarControlsView : SDPullNavigationBarView

@property (nonatomic, strong) NSArray* barItems;

- (void)layoutWithBarItems:(NSArray*)barItems;

// Control items API
- (void)addBarItem:(UIView*)view;
- (void)addBarItemSpacerWithWidth:(CGFloat)spacerWidth;

@end
