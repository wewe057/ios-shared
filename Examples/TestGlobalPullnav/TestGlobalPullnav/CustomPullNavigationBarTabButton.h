//
//  CustomPullNavigationBarTabButton.h
//  ios-shared
//
//  Created by Steven Woolgar on 02/10/2014.
//  Copyright 2014 SetDirection. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SDPullNavigationBarTabButton.h"

@class SDPullNavigationBar;

@interface CustomPullNavigationBarTabButton : SDPullNavigationBarTabButton

@property (nonatomic, assign) BOOL tuckedTab;

- (id)initWithNavigationBar:(SDPullNavigationBar*)navigationBar;

@end
