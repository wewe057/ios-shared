//
//  SDPullNavigationBarTabButton.h
//  ios-shared

//
//  Created by Brandon Sneed on 11/06/2013.
//  Copyright 2013-2014 SetDirection. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SDPullNavigationBar;

@interface SDPullNavigationBarTabButton : UIView

@property (nonatomic, assign) BOOL tuckedTab;

- (id)initWithNavigationBar:(SDPullNavigationBar*)navigationBar;

@end

#pragma mark - Adornment view (derived for ease of debugging and gesture handling)

@interface SDPullNavigationBarAdornmentView : UIImageView
@end
