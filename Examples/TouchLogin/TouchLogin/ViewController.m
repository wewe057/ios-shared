//
//  ViewController.m
//  TouchLogin
//
//  Created by Sam Grover on 7/2/14.
//  Copyright (c) 2014 Walmart. All rights reserved.
//

#import "ViewController.h"
#import "SDAuthentication.h"
#import "SDKeychain.h"

@interface ViewController ()

@property (nonatomic, strong) IBOutlet UITextField* usernameField;
@property (nonatomic, strong) IBOutlet UITextField* passwordField;

@property (nonatomic, copy) NSString* username;
@property (nonatomic, copy) NSString* password;
@property (nonatomic, copy) NSString* serviceName;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.usernameField.enabled = NO;
    self.usernameField.text = self.username = @"sam@example.com";
    self.passwordField.text = self.password = @"password";
    self.serviceName = @"com.touchlogin.touchidtest";
}

- (IBAction)saveButtonTapped:(id)sender
{
    self.password = self.passwordField.text;
    NSError* keyChainError = nil;
    [SDKeychain storeUsername:self.username
                  andPassword:self.password
               forServiceName:self.serviceName
               updateExisting:YES
                        error:&keyChainError];
    if (keyChainError) {
        SDLog(@"There was an error in storing the password: %@", keyChainError);
    } else {
        SDLog(@"Updated password to: %@", self.password);
    }
}

- (IBAction)retrieveButtonTapped:(id)sender
{
    [self.usernameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
    [self requestAccess];
}

-  (void)requestAccess
{
    [SDAuthentication authenticateUsername:self.username
                               serviceName:self.serviceName
                           localizedReason:@"access plz. kthnxbye."
                  presentingViewController:self
                                replyBlock:^(BOOL success, NSError *error)
    {
        if (success)
        {
            SDLog(@"AUTHENTICATION SUCCEEDED!");
        }
        else
        {
            SDLog(@"AUTHENTICATION FAILED! Error: %@", error);
        }
    }];
}

@end
