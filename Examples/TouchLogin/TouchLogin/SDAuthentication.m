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

+ (void)authenticateForLocalizedReason:(NSString*)localizedReason
                            replyBlock:(SDAuthenticationReply)replyBlock
                         fallbackBlock:(SDAuthenticationFallbackBlock)fallbackBlock
{
#if !TARGET_IPHONE_SIMULATOR
    LAContext* context = [[LAContext alloc] init];
    NSError* authError = nil;
    
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&authError])
    {
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                localizedReason:localizedReason
                          reply:^(BOOL success, NSError* error)
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 if (success)
                 {
                     if (replyBlock)
                     {
                         replyBlock(YES, error);
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
                             if (fallbackBlock) {
                                 fallbackBlock(error);
                             }
                             break;
                             
                         case kLAErrorUserCancel:
                         case kLAErrorSystemCancel:
                         case kLAErrorAuthenticationFailed:
                             if (replyBlock)
                             {
                                 SDLog(@"TouchID authentication did not succeed: %@", error);
                                 replyBlock(NO, error);
                             }
                             break;
                     }
                 }
             });
         }];
    }
    else
#endif // !TARGET_IPHONE_SIMULATOR
    {
        // Cannot evaluate policy. TouchID is not available or not configured. Use fallback.
        SDLog(@"Cannot evaluate policy: %@", authError);
        if (fallbackBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                fallbackBlock(authError);
            });
        }
    }
}

+ (void)authenticateUsername:(NSString*)username
                 serviceName:(NSString*)serviceName
             localizedReason:(NSString*)localizedReason
    presentingViewController:(UIViewController*)presentingViewController
                  replyBlock:(SDAuthenticationReply)replyBlock
{
    SDAuthenticationFallbackBlock fallbackBlock = ^(NSError* error) {
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
                if (replyBlock)
                {
                    replyBlock(NO, promptError);
                }
            }
            
            BOOL validPassword = [storedPassword isEqualToString:enteredPassword];
            
            // Compare to password in keychain and call completion block
            if (replyBlock)
            {
                promptError = [NSError errorWithDomain:SDAuthenticationErrorDomain
                                                  code:SDAuthenticationErrorPasswordMismatch
                                              userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"Entered password does not match stored password.", @"SDAuthentication: password mismatch error") }];
                replyBlock(validPassword, promptError);
            }
            
            [alertController dismissViewControllerAnimated:YES completion:nil];
        }];
        
        [alertController addAction:defaultAction];
        [presentingViewController presentViewController:alertController animated:YES completion:nil];
    };

    [SDAuthentication authenticateForLocalizedReason:localizedReason replyBlock:replyBlock fallbackBlock:fallbackBlock];
}
@end
