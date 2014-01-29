//
//  SDAutolayoutStackView.h
//  StackedContainerViewDemo
//
//  Created by Tim Trautmann on 1/28/14.
//  Copyright (c) 2014 Wal-mart Stores, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 Similar to SDStackView, this class provides a view for displaying a set of views
 in an ordered visual stack using auto layout techniques.
 */

@interface SDAutolayoutStackView : UIView

/**
 The inset margins for the subviews. (Default is 0 for each inset)
 */
@property (nonatomic, assign) UIEdgeInsets edgeInsets;

/**
 The gap between each subview.
 */
@property (nonatomic, assign) CGFloat gap;

/**
 updateConstraints must be called when removing subviews.
 */
- (void)updateConstraints;

@end
