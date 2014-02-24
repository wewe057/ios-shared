//
//  SDCreditCardField.h
//  SetDirection
//
//  Created by Alex MacCaw on 01/22/2013.
//  Copyright (c) 2013 Stripe. All rights reserved.
//
//  Adapted by Steven Woolgar on 02/24/2014
//

#import <UIKit/UIKit.h>

#import "SDCard.h"
#import "SDCardNumber.h"

@class SDCreditCardField;
@class SDCCTextField;

typedef NS_ENUM(NSUInteger, SDCreditCardImageStyle)
{
	SDCreditCardImageStyleNormal,
    SDCreditCardImageStyleOutline
};

@protocol SDCreditCardFieldDelegate <NSObject>
@optional
- (void)paymentView:(SDCreditCardField*)paymentView withCard:(SDCard*)card isValid:(BOOL)valid;
- (void)paymentViewDidChangeState:(SDCreditCardField*)paymentView;
@end

@interface SDCreditCardField : UIView

- (BOOL)isValid;

@property(nonatomic, assign) UITextBorderStyle borderStyle;
@property(nonatomic, assign) SDCreditCardImageStyle imageStyle;
@property(nonatomic, strong) UIFont* font;
@property(nonatomic, strong) UIColor* textColor;
@property(nonatomic, copy) NSDictionary* defaultTextAttributes;

@property (nonatomic, readonly) UIView* opaqueOverGradientView;
@property (nonatomic, readonly) SDCardNumber* cardNumber;

@property (nonatomic, strong) UIView* innerView;
@property (nonatomic, strong) UIView* clipView;
@property (nonatomic, strong) SDCCTextField* cardNumberField;
@property (nonatomic, strong) UITextField* cardLastFourField;
@property (nonatomic, strong) UIImageView* placeholderView;
@property (nonatomic, strong) SDCard* card;
@property (nonatomic, weak) id<SDCreditCardFieldDelegate> delegate;

@end
