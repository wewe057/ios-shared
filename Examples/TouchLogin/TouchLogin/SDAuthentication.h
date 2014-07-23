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
 *  @param error Output parameter that returns the appropriate error object in case of failure. The error domain can be 
 */
typedef void(^SDAuthenticationReply)(BOOL success, NSError* error);

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
 *  Authenticate a user.
 *
 *  @param username The username whose account needs to be authenticated. Must match the saved previously password.
 *  @param serviceName The service name used to store the username and password in the keychain.
 *  @param localizedReason The reason for authentication. This is shown in the TouchID prompt and also the fallback password prompt.
 *  @param presentingViewController The view controller from which to present the fallback prompt.
 *  @param useTouchID A bool to indicate whether to use TouchID or not.
 *  @param reply The authentication response block.
 *
 */
+ (void)authenticateUsername:(NSString*)username
                 serviceName:(NSString*)serviceName
             localizedReason:(NSString*)localizedReason
    presentingViewController:(UIViewController*)presentingViewController
                  useTouchID:(BOOL)useTouchID
                       reply:(SDAuthenticationReply)reply;

@end
