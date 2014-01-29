//
//  SDAutolayoutStackView.m
//  StackedContainerViewDemo
//
//  Created by Tim Trautmann on 1/28/14.
//  Copyright (c) 2014 Wal-mart Stores, Inc. All rights reserved.
//

#import "SDAutolayoutStackView.h"

@implementation SDAutolayoutStackView

// When a view has been added to this container, call updateConstraints.
- (void)didAddSubview:(UIView *)subview
{
    [super didAddSubview:subview];
    [self updateConstraints];
}

- (void)updateConstraints
{
    [super updateConstraints];
    
    // Remove all constraints on this container view.
    [self removeConstraints:self.constraints];
    
    NSLayoutConstraint *bottomConstraint = nil;
    UIView *previousView = nil;
    
    for (UIView *view in self.subviews)
    {
        // If this is the topmost view, attach it to the parent view at the top.
        if ([self.subviews.firstObject isEqual:view])
        {
            [self addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                             attribute:NSLayoutAttributeTop
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self
                                                             attribute:NSLayoutAttributeTop
                                                            multiplier:1.0
                                                              constant:self.edgeInsets.top]];
        }
        // Otherwise attach this view to the previous view's bottom.
        else
        {
            [self addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                             attribute:NSLayoutAttributeTop
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:previousView
                                                             attribute:NSLayoutAttributeBottom
                                                            multiplier:1.0
                                                              constant:self.gap]];
        }
        
        // All child views have leading and trailing constraints.
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(left)-[view]-(right)-|"
                                                                     options:0
                                                                     metrics:@{ @"left" : @(self.edgeInsets.left),
                                                                                @"right" : @(self.edgeInsets.right) }
                                                                       views:NSDictionaryOfVariableBindings(view)]];
        
        // If there is already a bottom constraint, remove it.
        if (bottomConstraint)
            [self removeConstraint:bottomConstraint];
        
        
        // Add a bottom constraint to attach view to the bottom of container
        // view.
        bottomConstraint = [NSLayoutConstraint constraintWithItem:view
                                                        attribute:NSLayoutAttributeBottom
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeBottom
                                                       multiplier:1.0
                                                         constant:-self.edgeInsets.bottom];
        
        [self addConstraint:bottomConstraint];
        
        // Set this view to previousView for next iteration of this loop.
        previousView = view;
    }
}

@end
