//
//  NSArray+SDExtensions.m
//  navbar2
//
//  Created by Brandon Sneed on 7/26/11.
//  Copyright 2011 Walmart. All rights reserved.
//

#import "NSArray+SDExtensions.h"

@implementation NSMutableArray (SDExtensions)

- (void)shuffle
{
	for (NSInteger i = [self count] - 1; i > 0; --i) {
		[self exchangeObjectAtIndex: arc4random() % (i+1) withObjectAtIndex: i];
	}
}

@end


@implementation NSArray (SDExtensions)

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
    va_start(args, arg1);
    
    NSArray *items = [self copy];
    for (id object in items)
    {
        if ([object respondsToSelector:aSelector])
        {
            NSMethodSignature *methodSig = [[object class] instanceMethodSignatureForSelector:aSelector];
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature: methodSig];
            [invocation setTarget:object];
            [invocation setSelector:aSelector];
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

- (NSArray*)shuffledArray
{
	NSMutableArray* shuffledArray = [NSMutableArray arrayWithArray: self];
	[shuffledArray shuffle];
	return shuffledArray;
}

// From: http://stackoverflow.com/a/586529/27153
- (NSArray *)reversedArray
{
	return [[self reverseObjectEnumerator] allObjects];
}

- (NSString *)JSONStringRepresentation
{
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:self options:0 error:&error];
    if (error)
        SDLog(@"error converting event into JSON: %@", error);
    NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return result;
}

- (NSData *)JSONRepresentation
{
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:self options:0 error:&error];
    if (error)
        SDLog(@"error converting event into JSON: %@", error);
    return data;
}


@end
