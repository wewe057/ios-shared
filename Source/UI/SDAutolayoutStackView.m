//
//  SDAutolayoutStackView.m
//  StackedContainerViewDemo
//
//  Created by Tim Trautmann on 1/28/14.
//  Copyright (c) 2014 Wal-mart Stores, Inc. All rights reserved.
//

#import "SDAutolayoutStackView.h"

@implementation SDAutolayoutStackView

- (void)didAddSubview:(UIView *)subview
{
    [super didAddSubview:subview];
    [self updateConstraints];
}

- (void)updateConstraints
{
    [super updateConstraints];
    [self removeConstraints:self.constraints];
    
    NSLayoutConstraint *bottomConstraint = nil;
    UIView *previousView = nil;
    
    for (UIView *view in self.subviews)
    {
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
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(left)-[view]-(right)-|"
                                                                     options:0
                                                                     metrics:@{ @"left" : @(self.edgeInsets.left),
                                                                                @"right" : @(self.edgeInsets.right) }
                                                                       views:NSDictionaryOfVariableBindings(view)]];
        
        if (bottomConstraint)
            [self removeConstraint:bottomConstraint];
        
        bottomConstraint = [NSLayoutConstraint constraintWithItem:view
                                                        attribute:NSLayoutAttributeBottom
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeBottom
                                                       multiplier:1.0
                                                         constant:-self.edgeInsets.bottom];
        
        [self addConstraint:bottomConstraint];
        previousView = view;
    }
}

@end
