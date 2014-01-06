//
//  SDPullNavigationBarControlsView.h
//  walmart
//
//  This is a simple list of controls that live in the pullnav.
//
//  Created by Steven Woolgar on 12/06/2013.
//  Copyright (c) 2013 Walmart. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SDPullNavigationBarControlsView : UIView

@property (nonatomic, strong) UIBarButtonItem* owningBarButtonItem;
@property (nonatomic, assign) UIRectEdge edge;
@property (nonatomic, strong) NSArray* barItems;

- (instancetype)initWithEdge:(UIRectEdge)edge;

- (void)layoutWithBarItems:(NSArray*)barItems;

// Control items API
- (void)addBarItem:(UIView*)view;
- (void)addBarItemSpacerWithWidth:(CGFloat)spacerWidth;

@end
