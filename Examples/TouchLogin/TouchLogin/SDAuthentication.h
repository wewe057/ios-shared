//
//  SDAuthentication.h
//  TouchLogin
//
//  Created by Sam Grover on 7/10/14.
//  Copyright (c) 2014 Walmart. All rights reserved.
//

@import UIKit;

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
