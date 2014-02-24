//
//  SDCreditCardField.m
//  SetDirection
//
//  Created by Alex MacCaw on 01/22/2013.
//  Copyright (c) 2013 Stripe. All rights reserved.
//
//  Adapted by Steven Woolgar on 02/24/2014
//

#import "SDCreditCardField.h"

#import "SDCCTextField.h"

#import <QuartzCore/QuartzCore.h>

@interface SDCreditCardField () <UITextFieldDelegate>

@property (nonatomic, assign, getter = isInitialState) BOOL initialState;
@property (nonatomic, assign, getter = isValidState) BOOL validState;

@end

@implementation SDCreditCardField

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self != nil)
    {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder*)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self != nil)
    {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    _borderStyle = UITextBorderStyleRoundedRect;

    self.layer.masksToBounds = YES;
    self.backgroundColor = [UIColor whiteColor];

    _initialState = YES;
    _validState   = NO;

    [self setupPlaceholderView];

    _innerView = [[UIView alloc] initWithFrame:(CGRect){ CGPointZero, { 0.0f, self.frame.size.height } }];
    _innerView.clipsToBounds = YES;

    _cardLastFourField = [[UITextField alloc] init];
    _cardLastFourField.defaultTextAttributes = _defaultTextAttributes;
    _cardLastFourField.backgroundColor = self.backgroundColor;

    [self setupCardNumberField];

    self.defaultTextAttributes = @{ NSFontAttributeName : [UIFont boldSystemFontOfSize:16.0f],
    NSForegroundColorAttributeName : [UIColor blackColor] };

    [_innerView addSubview:_cardNumberField];

    [self addSubview:_innerView];
    [self addSubview:_placeholderView];

    UIView* line = [[UIView alloc] initWithFrame:(CGRect){ { _placeholderView.frame.size.width - 0.5f, 0.0f }, { 0.5f, _innerView.frame.size.height } }];
    line.backgroundColor = [UIColor colorWithRed:0.5f green:0.5f blue:0.5f alpha:0.3f];
    [self addSubview:line];

    [self stateCardNumber];
}

- (void)setBorderStyle:(UITextBorderStyle)borderStyle
{
    if(_borderStyle != borderStyle)
    {
        _borderStyle = borderStyle;
        
        if(borderStyle == UITextBorderStyleRoundedRect)
        {
            self.layer.borderColor = [UIColor colorWithRed:191.0f/255.0f green:192.0f/255.0f blue:194.0f/255.0f alpha:1.0f].CGColor;
            self.layer.cornerRadius = 6.0f;
            self.layer.borderWidth = 0.5f;
        }
        else
        {
            self.layer.borderColor = nil;
            self.layer.cornerRadius = 0.0f;
            self.layer.borderWidth = 0.0f;
        }
    }
}

- (void)setDefaultTextAttributes:(NSDictionary*)defaultTextAttributes
{
    if(_defaultTextAttributes != defaultTextAttributes)
    {
        _defaultTextAttributes = [defaultTextAttributes copy];
        
        // We shouldn't need to set the font and textColor attributes, but a bug exists in 7.0 (fixed in 7.1/)

        self.cardNumberField.defaultTextAttributes = _defaultTextAttributes;
        self.cardNumberField.font = _defaultTextAttributes[NSFontAttributeName];
        self.cardNumberField.textColor = _defaultTextAttributes[NSForegroundColorAttributeName];
        self.cardNumberField.textAlignment = NSTextAlignmentLeft;

        [self setNeedsLayout];
    }
}

- (UIFont*)font
{
    return self.defaultTextAttributes[NSFontAttributeName];
}

- (void)setFont:(UIFont*)font
{
    NSMutableDictionary* defaultTextAttributes = [self.defaultTextAttributes mutableCopy];
    defaultTextAttributes[NSFontAttributeName] = font;

    self.defaultTextAttributes = [defaultTextAttributes copy];
}

- (UIColor*)textColor
{
    return self.defaultTextAttributes[NSForegroundColorAttributeName];
}

- (void)setTextColor:(UIColor*)textColor
{
    NSMutableDictionary* defaultTextAttributes = [self.defaultTextAttributes mutableCopy];
    defaultTextAttributes[NSForegroundColorAttributeName] = textColor;

    self.defaultTextAttributes = [defaultTextAttributes copy];
}

- (SDCCTextField*)textFieldWithPlaceholder:(NSString*)placeholder
{
    SDCCTextField* textField = [[SDCCTextField alloc] init];

    textField.delegate = self;
    textField.placeholder = placeholder;
    textField.keyboardType = UIKeyboardTypeNumberPad;
    textField.defaultTextAttributes = _defaultTextAttributes;
    textField.layer.masksToBounds = NO;

    return textField;
}

- (void)setupPlaceholderView
{
    _placeholderView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"placeholder"]];
    _placeholderView.backgroundColor = [UIColor whiteColor];
}

- (void)setupCardNumberField
{
    _cardNumberField = [self textFieldWithPlaceholder:@"1234 5678 9012 3456"];
}

// Accessors

- (SDCardNumber*)cardNumber
{
    return [SDCardNumber cardNumberWithString:_cardNumberField.text];
}

- (void)layoutSubviews
{
    _placeholderView.frame = CGRectMake(0.0f, (self.frame.size.height - 32.0f) * 0.5f, 51.0f, 32.0f);

    NSDictionary* attributes = self.defaultTextAttributes;

    CGSize lastGroupSize;
    CGSize cardNumberSize;

    if(self.cardNumber.cardType == SDCardTypeAmex)
    {
        cardNumberSize = [@"1234 567890 12345" sizeWithAttributes:attributes];
        lastGroupSize = [@"00000" sizeWithAttributes:attributes];
    }
    else
    {
        if(self.cardNumber.cardType == SDCardTypeDinersClub)
        {
            cardNumberSize = [@"1234 567890 1234" sizeWithAttributes:attributes];
        }
        else
        {
            cardNumberSize = [_cardNumberField.placeholder sizeWithAttributes:attributes];
        }

        lastGroupSize = [@"0000" sizeWithAttributes:attributes];
    }

    CGFloat textFieldY = (self.frame.size.height - lastGroupSize.height) / 2.0;
    CGFloat innerWidth = self.frame.size.width - _placeholderView.frame.size.width;

    _cardNumberField.frame = (CGRect){ { (innerWidth * 0.5f) - (cardNumberSize.width * 0.5f), textFieldY }, cardNumberSize };
    _cardLastFourField.frame = (CGRect){ { CGRectGetMaxX(_cardNumberField.frame) - lastGroupSize.width, textFieldY }, lastGroupSize };

    CGFloat x = _innerView.frame.origin.x;

    if(_initialState)
    {
        x = _placeholderView.frame.size.width;
    }

    _innerView.frame = CGRectMake(x, 0.0f, CGRectGetMaxX(self.cardLastFourField.frame), self.frame.size.height);
}

// State

- (void)stateCardNumber
{
    @strongify(self.delegate, delegate);
    if([delegate respondsToSelector:@selector(paymentViewDidChangeState:)])
    {
        [delegate paymentViewDidChangeState:self];
    }

    if(!_initialState)
    {
        // Animate left
        _initialState = YES;

        [UIView animateWithDuration:0.400
                              delay:0
                            options:(UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionAllowUserInteraction)
                         animations:^
        {
            _innerView.frame = (CGRect){ { _placeholderView.frame.size.width, 0.0f }, _innerView.frame.size };
            _cardNumberField.alpha = 1.0f;
        }
        completion:^(BOOL completed) {}];
    }
    
    if(self.isFirstResponder)
    {
        [self.cardNumberField becomeFirstResponder];
    }
}

- (void)stateMeta
{
    _initialState = NO;

    _cardLastFourField.text = self.cardNumber.lastGroup;

    [_innerView addSubview:_cardLastFourField];
    
    CGFloat difference = -(_innerView.frame.size.width - self.frame.size.width + _placeholderView.frame.size.width);

    [UIView animateWithDuration:0.400
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^
    {
        _cardNumberField.alpha = 0.0;
        _innerView.frame = CGRectOffset(_innerView.frame, difference, 0);
    } completion:nil];
}

- (BOOL)isValid
{
    return [self.cardNumber isValid];
}

- (SDCard*)card
{
    SDCard* card = [[SDCard alloc] init];
    card.number   = [self.cardNumber string];

    return card;
}

- (void)setCard:(SDCard*)card
{
    [self reset];
    SDCardNumber* number = [[SDCardNumber alloc] initWithString:card.number];
    self.cardNumberField.text = [number formattedString];
    [self setPlaceholderToCardType];
    [self stateMeta];
}

- (void)reset
{
    [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self commonInit];
    [self layoutSubviews];
}

- (void)setPlaceholderViewImage:(UIImage*)image
{
    NSAssert(image, @"Seeting a nil image for the credit card image.");

    if(![_placeholderView.image isEqual:image])
    {
        __block __unsafe_unretained UIView* previousPlaceholderView = _placeholderView;
        [UIView animateWithDuration:0.25
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^
        {
             _placeholderView.layer.opacity = 0.0;
             _placeholderView.layer.transform = CATransform3DMakeScale(1.2f, 1.2f, 1.2f);
        }
        completion:^(BOOL finished)
        {
             [previousPlaceholderView removeFromSuperview];
        }];

        _placeholderView = nil;
        
        [self setupPlaceholderView];
        _placeholderView.image = image;
        _placeholderView.layer.opacity = 0.0;
        _placeholderView.layer.transform = CATransform3DMakeScale(0.8f, 0.8f, 0.8f);
        [self insertSubview:_placeholderView belowSubview:previousPlaceholderView];
        [UIView animateWithDuration:0.25
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^
        {
            _placeholderView.layer.opacity = 1.0;
            _placeholderView.layer.transform = CATransform3DIdentity;
        } completion:^(BOOL finished) {}];
    }
}

- (void)setPlaceholderToCardType
{
    SDCardNumber* cardNumber = [SDCardNumber cardNumberWithString:_cardNumberField.text];
    SDCardType cardType      = [cardNumber cardType];
    NSString* cardTypeName   = @"placeholder";

    switch(cardType)
    {
        case SDCardTypeAmex:
            cardTypeName = @"amex";
            break;
        case SDCardTypeDinersClub:
            cardTypeName = @"diners";
            break;
        case SDCardTypeDiscover:
            cardTypeName = @"discover";
            break;
        case SDCardTypeJCB:
            cardTypeName = @"jcb";
            break;
        case SDCardTypeMasterCard:
            cardTypeName = @"mastercard";
            break;
        case SDCardTypeVisa:
            cardTypeName = @"visa";
            break;
        default:
            break;
    }

    [self setPlaceholderViewImage:[UIImage imageNamed:cardTypeName]];
}

// Delegates

- (void)textFieldDidBeginEditing:(UITextField*)textField
{
    [self setPlaceholderToCardType];

    if([textField isEqual:_cardNumberField] && !self.initialState)
    {
        [self stateCardNumber];
    }
}

- (BOOL)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)replacementString
{
    if([textField isEqual:_cardNumberField])
    {
        return [self cardNumberFieldShouldChangeCharactersInRange:range replacementString:replacementString];
    }

    return YES;
}

- (void)ccTextFieldDidBackSpaceWhileTextIsEmpty:(SDCCTextField*)textField
{
    [self stateCardNumber];
}

- (BOOL)cardNumberFieldShouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)replacementString
{
    NSString* resultString = [self.cardNumberField.text stringByReplacingCharactersInRange:range withString:replacementString];
    resultString = [SDCCTextField textByRemovingUselessSpacesFromString:resultString];
    SDCardNumber* cardNumber = [SDCardNumber cardNumberWithString:resultString];

    BOOL valid = NO;

    if([cardNumber isPartiallyValid])
    {
        if(replacementString.length > 0)
        {
            self.cardNumberField.text = [cardNumber formattedStringWithTrail];
        }
        else
        {
            self.cardNumberField.text = [cardNumber formattedString];
        }

        [self setPlaceholderToCardType];

        if([cardNumber isValid])
        {
            [self textFieldIsValid:self.cardNumberField];
            [self stateMeta];
        }
        else if([cardNumber isValidLength] && ![cardNumber isValidLuhn])
        {
            [self textFieldIsInvalid:self.cardNumberField withErrors:YES];
        }
        else if(![cardNumber isValidLength])
        {
            [self textFieldIsInvalid:self.cardNumberField withErrors:NO];
        }
    }

    return valid;
}

// Validations

- (void)checkValid
{
    @strongify(self.delegate, delegate);
    if([self isValid])
    {
        self.validState = YES;

        if([delegate respondsToSelector:@selector(paymentView:withCard:isValid:)])
        {
            [delegate paymentView:self withCard:self.card isValid:YES];
        }
    }
    else if(![self isValid] && self.validState)
    {
        self.validState = NO;
        
        if([delegate respondsToSelector:@selector(paymentView:withCard:isValid:)])
        {
            [delegate paymentView:self withCard:self.card isValid:NO];
        }
    }
}

- (void)textFieldIsValid:(SDCCTextField*)textField
{
    textField.textColor = _defaultTextAttributes[NSForegroundColorAttributeName];
    [self checkValid];
}

- (void)textFieldIsInvalid:(SDCCTextField*)textField withErrors:(BOOL)errors
{
    if(errors)
    {
        textField.textColor = [UIColor colorWithRed:253.0/255.0 green:0.0 blue:17.0/255.0 alpha:1.0];
    }
    else
    {
        textField.textColor = _defaultTextAttributes[NSForegroundColorAttributeName];
    }

    [self checkValid];
}

#pragma mark - UIResponder

- (UIResponder*)firstResponderField;
{
    return self.cardNumberField.isFirstResponder ? self.cardNumberField : nil;
}

- (SDCCTextField*)firstInvalidField;
{
    SDCCTextField* invalidField = nil;

    if(![[SDCardNumber cardNumberWithString:self.cardNumberField.text] isValid])
    {
        invalidField = self.cardNumberField;
    }

    return invalidField;
}

- (SDCCTextField*)nextFirstResponder;
{
    if(self.firstInvalidField)
    {
        return self.firstInvalidField;
    }

    return self.cardNumberField;
}

- (BOOL)isFirstResponder;
{
    return self.firstResponderField.isFirstResponder;
}

- (BOOL)canBecomeFirstResponder;
{
    return self.nextFirstResponder.canBecomeFirstResponder;
}

- (BOOL)becomeFirstResponder;
{
    return [self.nextFirstResponder becomeFirstResponder];
}

- (BOOL)canResignFirstResponder;
{
    return self.firstResponderField.canResignFirstResponder;
}

- (BOOL)resignFirstResponder;
{
    return [self.firstResponderField resignFirstResponder];
}

@end