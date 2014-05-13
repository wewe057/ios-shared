//
// Created by Steve Riggins on 4/9/14.
// Copyright (c) 2014 Walmart. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SDPaddedLabel : UIView
@property (nonatomic, assign) UIEdgeInsets      edgeInsets;
@property (nonatomic, strong, readonly) UILabel *label;
@end