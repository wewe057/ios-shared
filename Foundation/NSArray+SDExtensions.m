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
	for (NSUInteger i = [self count] - 1; i > 0; --i) {
		[self exchangeObjectAtIndex: arc4random() % (i+1) withObjectAtIndex: i];
	}
}

@end


@implementation NSArray (SDExtensions)

- (id)nextToLastObject
{
    NSUInteger count = [self count];
    if (count < 2)
        return nil;
    id result = [self objectAtIndex:count-2];
    return result;
}

// This is tightly tied to the implementation found in NSObject+SDExtensions.m
// These is a reason that the implementation is duplicated and not called into NSObject's version.
// Please keep them duplicated otherwise the recursion bug that is being solved will happen again.

- (void)callSelector:(SEL)aSelector argumentAddresses:(void *)arg1, ...
{
    #define kMaximumCallSelectorArguments 20

    // First, pull out all of the vararg params, store them on the stack. We only
    // need them extracted once for the entire array. We might be called recursively.

    va_list args;
    va_start(args, arg1);

    // Clear room for extraction of arguments.

    char *extractedArguments[kMaximumCallSelectorArguments] = { 0 };       // TODO: Determine maximum useful # of arguments.

    // Extract all the arguments, then close the vaargs to guard from recursion issues.

    char *currentArgument = (char *)arg1;
    unsigned int argumentIndex = 0;
    extractedArguments[argumentIndex++] = currentArgument;

    for (currentArgument = arg1; currentArgument != NULL; currentArgument = va_arg(args, void *))
    {
        if (argumentIndex == kMaximumCallSelectorArguments)
            break;
        extractedArguments[argumentIndex++] = va_arg(args, void *);
    }

    va_end( args );

    // Now use the extracted vararg params on the list of items.

    NSArray* items = [self copy];
    for (id object in items)
    {
        if ([object respondsToSelector: aSelector])
        {
            NSMethodSignature *methodSig = [[object class] instanceMethodSignatureForSelector:aSelector];
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature: methodSig];
            [invocation setTarget: object];
            [invocation setSelector: aSelector];
            unsigned int argumentIndex = 0;
            void *theArg = extractedArguments[argumentIndex++];
            if( theArg )
                [invocation setArgument:&theArg atIndex:2];
            for( int i = 3; i < [methodSig numberOfArguments]; ++i )
            {
                theArg = extractedArguments[argumentIndex++];
                if (theArg)
                    [invocation setArgument:&theArg atIndex:i];
            }
            [invocation invoke];
        }
    }
}

- (NSArray *)shuffledArray
{
	NSMutableArray *shuffledArray = [NSMutableArray arrayWithArray: self];
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
