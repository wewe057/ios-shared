//
//  SDAuthentication.m
//  TouchLogin
//
//  Created by Sam Grover on 7/10/14.
//  Copyright (c) 2014 Walmart. All rights reserved.
//

#if !TARGET_IPHONE_SIMULATOR
@import LocalAuthentication;
#endif

#import "SDAuthentication.h"
#import "SDKeychain.h"

NSString* const SDAuthenticationErrorDomain = @"SDAuthenticationErrorDomain";

@implementation SDAuthentication

+ (void)authenticateUsername:(NSString*)username
                 serviceName:(NSString*)serviceName
             localizedReason:(NSString*)localizedReason
    presentingViewController:(UIViewController*)presentingViewController
                  useTouchID:(BOOL)useTouchID
                       reply:(SDAuthenticationReply)reply
{
    void (^passwordPromptFallbackBlock)() = ^{
        UIAlertController* alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Enter Password", @"Enter Password")
                                                                                 message:localizedReason
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
         {
             textField.secureTextEntry = YES;
         }];
        
        @weakify(alertController);
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Done", @"Done")
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action)
        {
            @strongify(alertController);
            NSError* promptError = nil;
            UITextField* passwordField = alertController.textFields[0];
            NSString* enteredPassword = passwordField.text;
            NSString* storedPassword = [SDKeychain getPasswordForUsername:username andServiceName:serviceName error:&promptError];
            if (promptError) {
                // Compare to password in keychain and call completion block
                if (reply)
                {
                    reply(NO, promptError);
                }
            }
            
            BOOL validPassword = [storedPassword isEqualToString:enteredPassword];
            
            // Compare to password in keychain and call completion block
            if (reply)
            {
                promptError = [NSError errorWithDomain:SDAuthenticationErrorDomain
                                                  code:SDAuthenticationErrorPasswordMismatch
                                              userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"Entered password does not match stored password.", @"SDAuthentication: password mismatch error") }];
                reply(validPassword, promptError);
            }
            
            [alertController dismissViewControllerAnimated:YES completion:nil];
        }];
        
        [alertController addAction:defaultAction];
        [presentingViewController presentViewController:alertController animated:YES completion:nil];
    };
    
#if !TARGET_IPHONE_SIMULATOR
    if (useTouchID)
    {
        LAContext* context = [[LAContext alloc] init];
        NSError* authError = nil;
        
        if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&authError])
        {
            [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                    localizedReason:localizedReason
                              reply:^(BOOL success, NSError* error)
            {
                if (success)
                {
                    NSString* storedPassword = [SDKeychain getPasswordForUsername:username andServiceName:serviceName error:nil];
                    SDLog(@"Authentication succeeded. Password is: %@", storedPassword);
                    
                    if (reply)
                    {
                        reply(YES, error);
                    }
                }
                else
                {
                    // User did not authenticate successfully, handle in fallback, or return failure appropriately.
                    switch (error.code)
                    {
                        case kLAErrorUserFallback:
                        case kLAErrorTouchIDNotAvailable:
                        case kLAErrorTouchIDNotEnrolled:
                        case kLAErrorPasscodeNotSet:
                            passwordPromptFallbackBlock();
                            break;
                            
                        case kLAErrorUserCancel:
                        case kLAErrorSystemCancel:
                        case kLAErrorAuthenticationFailed:
                            if (reply)
                            {
                                SDLog(@"TouchID authentication did not succeed: %@", error);
                                reply(NO, error);
                            }
                            break;
                    }
                }
            }];
        }
        else
        {
            // Cannot evaluate policy. TouchID is not available or not configured. Use fallback.
            SDLog(@"Cannot evaluate policy: %@", authError);
            passwordPromptFallbackBlock();
        }
    }
    else
    {
#endif
        passwordPromptFallbackBlock();
    }
#if !TARGET_IPHONE_SIMULATOR
}
#endif

@end
