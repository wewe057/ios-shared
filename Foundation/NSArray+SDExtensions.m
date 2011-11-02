//
//  NSArray+SDExtensions.m
//  navbar2
//
//  Created by Brandon Sneed on 7/26/11.
//  Copyright 2011 Walmart. All rights reserved.
//

#import "NSArray+SDExtensions.h"

@implementation NSArray (NSArray_SDExtensions)

- (id)nextToLastObject
{
    int count = [self count];
    if (count < 2)
        return nil;
    id result = [self objectAtIndex:count-2];
    return result;
}

- (void)callSelector:(SEL)aSelector argumentAddresses:(void *)arg1, ...
{
    va_list args;
    
    NSArray *items = [self copy];
    for (id object in items)
    {
        if ([object respondsToSelector:aSelector])
        {
            NSMethodSignature *methodSig = [[object class] instanceMethodSignatureForSelector:aSelector];
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature: methodSig];
            [invocation setTarget:object];
            [invocation setSelector:aSelector];
            va_start(args, arg1);
            if (arg1)
                [invocation setArgument:&arg1 atIndex:2];
            void *theArg = nil;
            for (int i = 3; i < [methodSig numberOfArguments]; i++)
            {
                theArg = va_arg(args, void *);
                if (theArg)
                    [invocation setArgument:&theArg atIndex:i];
            }
            [invocation invoke];	
            // don't process the results.
            //if (result)
            //    [invocation getReturnValue:result];
        }
    }
    va_end(args);
}

@end
