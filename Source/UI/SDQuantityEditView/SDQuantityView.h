//
//  ASDATrolleyQuantityView.h
//  asda
//
//  Created by ricky cancro on 10/31/13.
//  Copyright (c) 2013 Asda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDPaintCodeButton.h"

/**
 A circular button with a + in the center.  Used in the SDQuantityView
 */
@interface SDCircularPlusButton : SDPaintCodeButton
@property (nonatomic, strong) UIColor *strokeColor;
@property (nonatomic, strong) UIColor *highlightedColor;
+ (instancetype)circularPlusButtonWithStrokeColor:(UIColor *)strokeColor;
@end

/**
 A circular button with a - in the center.  Used in the SDQuantityView
 */
@interface SDCircularMinusButton : SDPaintCodeButton
@property (nonatomic, strong) UIColor *strokeColor;
@property (nonatomic, strong) UIColor *highlightedColor;
+ (instancetype)circularMinusButtonWithStrokeColor:(UIColor *)strokeColor;
@end

/**
 A simple view that displays an increment and decrement button with a label in the center
 to create a simple quantity changing control.
 */
@interface SDQuantityView : UIView

@property (nonatomic, strong) UILabel *quantityLabel;
@property (nonatomic, strong, readonly) SDCircularPlusButton *incrementButton;
@property (nonatomic, strong, readonly) SDCircularMinusButton *decrementButton;

/**
 The background color that "connects" the increment and decrement button.  Note this is
 not called "backgroundColor" since that already exists in UIView.
 */
@property (nonatomic, strong) UIColor *fillColor;

+ (instancetype)quantityView;

@end
