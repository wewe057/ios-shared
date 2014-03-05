//
//  SDPullNavigationBarAdornmentView.h
//  ios-shared
//
//  Created by Steven Woolgar on 03/01/2014.
//  Copyright 2014 SetDirection. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - Adornment view (derived for ease of debugging and gesture handling)

@interface SDPullNavigationBarAdornmentView : UIView
@property (nonatomic, strong) UIView* containerView;    // This is where the menu lives
@property (nonatomic, strong) UIImage* adornmentImage;  // This is where the optional adornment lives
@property (nonatomic, assign) CGRect baseFrame;         // If you set this I will account for the adornment view myself.
@end
