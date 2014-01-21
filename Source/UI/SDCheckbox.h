//
//  SDCheckbox.h
//  walmart
//
//  Created by Brandon Sneed on 1/15/14.
//  Copyright (c) 2014 Walmart. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SDCheckbox : UIControl

@property (nonatomic, strong) UIColor *checkboxColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) float checkboxWidth UI_APPEARANCE_SELECTOR;
@property (nonatomic, readonly) UILabel *textLabel;

@property (nonatomic, assign) BOOL checked;

@end
