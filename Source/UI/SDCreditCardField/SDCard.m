//
//  SDCard.m
//  SetDirection
//
//  Created by Alex MacCaw on 01/31/2013.
//  Copyright (c) 2013 Stripe. All rights reserved.
//
//  Adapted by Steven Woolgar on 02/24/2014
//

#import "SDCard.h"

@implementation SDCard

- (NSString*)last4
{
    NSString* result = nil;

    if(self.number.length >= 4)
    {
        result = [self.number substringFromIndex:(self.number.length - 4)];
    }

    return result;
}

@end
