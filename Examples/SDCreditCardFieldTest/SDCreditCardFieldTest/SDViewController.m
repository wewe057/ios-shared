//
//  SDViewController.m
//  SDCreditCardFieldTest
//
//  Created by Steven Woolgar on 02/23/2014.
//  Copyright (c) 2014 Steven Woolgar. All rights reserved.
//

#import "SDViewController.h"

#import "SDCreditCardField.h"

@interface SDViewController ()
@property (nonatomic, strong) IBOutlet SDCreditCardField* creditCardField;
@end

@implementation SDViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.creditCardField becomeFirstResponder];
}

@end
