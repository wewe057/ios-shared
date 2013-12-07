//
//  SDPullNavigationBarTabButton.h
//  walmart
//
//  Created by Brandon Sneed on 11/06/2013.
//  Copyright (c) 2013 Walmart. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SDPullNavigationBar;

@interface SDPullNavigationBarTabButton : UIView

@property (nonatomic, strong) UIImage* tabImage;
@property (nonatomic, assign) BOOL tuckedTab;

- (id)initWithNavigationBar:(SDPullNavigationBar*)navigationBar;

@end
