//
//  SDViewController.m
//  SDCreditCardFieldTest
//
//  Created by Steven Woolgar on 02/23/2014.
//  Copyright (c) 2014 Steven Woolgar. All rights reserved.
//

#import "SDViewController.h"

#import "SDCreditCardField.h"

@interface SDViewController ()<SDCreditCardFieldDelegate>
@property (nonatomic, strong) IBOutlet SDCreditCardField* creditCardField;
@property (nonatomic, strong) IBOutlet UIImageView* validImage;
@property (nonatomic, strong) IBOutlet UITextField* sampleCreditCardNumberField;
@property (nonatomic, strong) IBOutlet UIButton* fillButton;
@end

@implementation SDViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.creditCardField.delegate = self;
    [self.creditCardField becomeFirstResponder];
}

- (UIImage*)creditCardFieldCardImageForType:(SDCardType)type
{
    NSString* imageName = nil;
    switch(type)
    {
        case SDCardTypeVisa:
            imageName = @"cc-visa";
            break;
        case SDCardTypeMasterCard:
            imageName = @"cc-mastercard";
            break;
        case SDCardTypeAmex:
            imageName = @"cc-amex";
            break;
        case SDCardTypeDiscover:
            imageName = @"cc-discover";
            break;
        case SDCardTypeJCB:
            imageName = @"cc-jcb";
            break;
        case SDCardTypeDinersClub:
            imageName = @"cc-diners";
            break;
        case SDCardTypeSamsClub:
            imageName = @"cc-samsclub";
            break;
        case SDCardTypeSamsClubBusiness:
            imageName = @"cc-samsclub-business";
            break;
        default:
        case SDCardTypeUnknown:
            imageName = @"cc-placeholder";
            break;
    }

    return [UIImage imageNamed:imageName];
}

- (void)creditCardField:(SDCreditCardField*)creditCardField withCard:(SDCard*)card isValid:(BOOL)valid
{
    self.validImage.hidden = valid == NO;
}

- (void)creditCardFieldDidChangeState:(SDCreditCardField*)creditCardField
{
    SDLog(@"creditCardFieldDidChangeState:");
}

- (IBAction)pressedFillButton:(id)sender
{
    SDCard* card = [[SDCard alloc] init];
    card.number = self.sampleCreditCardNumberField.text;

    self.creditCardField.card = card;
    [self.creditCardField setNeedsDisplay];
}

@end
