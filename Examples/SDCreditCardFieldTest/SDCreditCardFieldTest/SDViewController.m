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
@end

@implementation SDViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.creditCardField becomeFirstResponder];
    self.creditCardField.delegate = self;
}

- (void)paymentView:(SDCreditCardField*)paymentView withCard:(SDCard*)card isValid:(BOOL)valid
{
    self.validImage.hidden = valid == NO;
}

- (void)paymentViewDidChangeState:(SDCreditCardField*)paymentView
{
    SDLog(@"paymentViewDidChangeState:");
}

@end
