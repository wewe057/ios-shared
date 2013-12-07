//
//  SDPullNavigationBarView.h
//  walmart
//
//  Created by Steven Woolgar on 12/05/2013.
//  Copyright (c) 2013 Walmart. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SDPullNavigationBarView : UIView

@property (nonatomic, strong) UIBarButtonItem* owningBarButtonItem;
@property (nonatomic, assign) UIRectEdge edge;

- (instancetype)initWithEdge:(UIRectEdge)edge;

@end
