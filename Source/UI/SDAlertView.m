//
//  SDAlertView.m
//  RxClient
//
//  Created by Brandon Sneed on 10/17/13.
//  Copyright 2013-2014 SetDirection. All rights reserved.
//

#import "SDAlertView.h"

@interface SDAlertView () <UIAlertViewDelegate>
@property (nonatomic, copy) SDAlertViewCompletionBlock completionBlock;
@end

@implementation SDAlertView

+ (instancetype)showAlertWithTitle:(NSString *)title
{
    return [[self class] showAlertWithTitle:title message:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil completion:nil];
}

+ (instancetype)showAlertWithTitle:(NSString *)title message:(NSString *)message
{
    return [[self class] showAlertWithTitle:title message:message cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil completion:nil];
}

+ (instancetype)showAlertWithTitle:(NSString *)title message:(NSString *)message completion:(SDAlertViewCompletionBlock)completionBlock
{
    return [[self class] showAlertWithTitle:title message:message cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil completion:completionBlock];
}

+ (instancetype)showAlertWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle completion:(SDAlertViewCompletionBlock)completionBlock
{
    return [[self class] showAlertWithTitle:title message:message cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil completion:completionBlock];
}

+ (instancetype)showAlertWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitle:(NSString *)otherButtonTitle completion:(SDAlertViewCompletionBlock)completionBlock
{
    return [[self class] showAlertWithTitle:title message:message cancelButtonTitle:cancelButtonTitle otherButtonTitles:@[otherButtonTitle] completion:completionBlock];
}

+ (instancetype)showAlertWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray *)otherButtonTitles completion:(SDAlertViewCompletionBlock)completionBlock
{
    SDAlertView *alertView = [[[self class] alloc] initWithTitle:title ? title : @"" message:message delegate:nil cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];
    alertView.delegate = alertView;

    for (NSString *buttonTitle in otherButtonTitles)
        [alertView addButtonWithTitle:buttonTitle];

    alertView.completionBlock = completionBlock;

    [alertView show];

    return alertView;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (self.completionBlock)
        self.completionBlock(alertView, buttonIndex);
}

@end
