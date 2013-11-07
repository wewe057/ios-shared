//
//  SDTextField.h
//
//  Created by Brandon Sneed on 11/7/13.
//  Copyright (c) 2013 SetDirection. All rights reserved.
//
//  Only slightly modified from RPFloatingPlaceholder* by Rob Phillips
//  The MIT License (MIT)
//
//  Copyright (c) 2013 Rob Phillips.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import <UIKit/UIKit.h>

@interface SDTextField : UITextField

/**
 The floating label that is displayed above the text field when there is other
 text in the text field.
 */
@property (nonatomic, strong, readonly) UILabel *floatingLabel;

/**
 The color of the floating label displayed above the text field when it is in
 an active state (i.e. the associated text view is first responder).

 @discussion Note: Tint color is used by default if this is nil.
 */
@property (nonatomic, strong) UIColor *floatingLabelActiveTextColor UI_APPEARANCE_SELECTOR;

/**
 The color of the floating label displayed above the text field when it is in
 an inactive state (i.e. the associated text view is not first responder).

 @discussion Note: 70% gray is used by default if this is nil.
 */
@property (nonatomic, strong) UIColor *floatingLabelInactiveTextColor UI_APPEARANCE_SELECTOR;


@end
