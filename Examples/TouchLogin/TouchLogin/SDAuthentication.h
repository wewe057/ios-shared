//
//  SDAuthentication.h
//  TouchLogin
//
//  Created by Sam Grover on 7/10/14.
//  Copyright (c) 2014 Walmart. All rights reserved.
//

@import UIKit;

extern NSString* const SDAuthenticationErrorDomain;

NS_ENUM(NSUInteger, SDAuthenticationError)
{
    SDAuthenticationErrorPasswordMismatch // The stored password didn't match the password entered by the user.
};

/**
 *  A reply indicating the result of an authentication request.
 *
 *  @param success Returns YES if the authentication was successful, NO otherwise.
 *  @param error The appropriate error object in case of failure.
 */
typedef void(^SDAuthenticationReply)(BOOL success, NSError* error);

/**
 *  A fallback block for showing an alternative authentication mechanism, such as a login view controller.
 *  e.g. SDAuthenticationFallbackBlock fallbackBlock = ^(NSError* error) {
 *           [myViewController presentViewController:loginViewController animated:YES completion:nil];
 *       };
 *
 *
 *  @param error The appropriate error object so you know what caused authentication to fail and can then show an appropriate fallback.
 */
typedef void(^SDAuthenticationFallbackBlock)(NSError* error);

/**
 * The purpose of this class is to provide a mechanism to authenticate the user during a flow in an application.
 * If TouchID is available, we use it to authenticate the user.
 * Otherwise we fallback on a password entry field, and compare the entered password with one previously stored in the keychain.
 * In order to use this class you MUST have a previously saved authenticated password.
 *
 * Note that TouchID authenticates the user who owns the device and the password is authenticating the user who is signed into the account in your app. These can be two different people. This class assumes they are the same.
 */
@interface SDAuthentication : NSObject


/**
 *  Authenticate a user with TouchID. If TouchID is unavailable, present a fallback prompt to let the user enter a password that is compared against a stored password.
 *
 *  @param username The username whose account needs to be authenticated. Must match the saved previously password.
 *  @param serviceName The service name used to store the username and password in the keychain.
 *  @param localizedReason The reason for authentication. This is shown in the TouchID prompt and also the fallback password prompt.
 *  @param presentingViewController The view controller from which to present the fallback prompt.
 *  @param replyBlock The authentication response block.
 *
 */
+ (void)authenticateUsername:(NSString*)username
                 serviceName:(NSString*)serviceName
             localizedReason:(NSString*)localizedReason
    presentingViewController:(UIViewController*)presentingViewController
                  replyBlock:(SDAuthenticationReply)replyBlock;

/**
 *  Authenticate a user with TouchID. If TouchID is unavailable, execute the provided fallback block.
 *
 *  @param localizedReason The reason for authentication. This is shown in the TouchID prompt.
 *  @param replyBlock The authentication response block.
 *  @param fallbackBlock The fallback block in case TouchID is unavailable.
 *
 */
+ (void)authenticateForLocalizedReason:(NSString*)localizedReason
                            replyBlock:(SDAuthenticationReply)replyBlock
                         fallbackBlock:(SDAuthenticationFallbackBlock)fallbackBlock;

@end
