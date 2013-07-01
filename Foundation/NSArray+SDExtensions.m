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

- (void)makeObjectsPerformSelector:(SEL)aSelector argumentAddresses:(void *)arg1, ...
{
#define kMaximumCallSelectorArguments 20
    
    // if there's nothing in here, GTFO.
    if (self.count == 0)
        return;
    
    // get a sample of our target objects
    id sampleTarget = [self objectAtIndex:0];
    
    // if it doesn't respond to the selector we're about to send it, GTFO.
    if (![sampleTarget respondsToSelector:aSelector])
        return;
    
    NSMethodSignature *methodSig = [[sampleTarget class] instanceMethodSignatureForSelector:aSelector];
    NSUInteger numberOfArguments = [methodSig numberOfArguments] - 2;
    
    // it has more than 20 args???  Go smack the developer making methods w/ that many params.
    if (numberOfArguments >= kMaximumCallSelectorArguments)
        [NSException raise:@"SDException" format:@"makeObjectsPerformSelector:argumentAddresses: cannot take more than %i arguments.", kMaximumCallSelectorArguments];
    
    // get our args in order and make sure we don't send bullshit parameters, so clear it out.
    void *arguments[kMaximumCallSelectorArguments];
    memset(arguments, 0, sizeof(void *) * kMaximumCallSelectorArguments);
    
    // get our args out of the va_list, get ourselves a parameter count y0!
    va_list args;
    va_start(args, arg1);
    
    arguments[0] = arg1;
    for (NSUInteger i = 1; i < numberOfArguments; i++)
        arguments[i] = va_arg(args, void *);
    
    va_end(args);
    
    // make a copy of ourselves in case the array changes while we're iterating.
    NSArray *copyOfSelf = [self copy];
    
    // call those mofos.
    for (NSObject *object in copyOfSelf)
        if([object respondsToSelector:aSelector])
        {
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature: methodSig];
            [invocation setTarget:object];
            [invocation setSelector:aSelector];
            
            void *theArg = nil;
            for (NSInteger i = 0; i < numberOfArguments; i++)
            {
                theArg = arguments[i];
                [invocation setArgument:theArg atIndex:i + 2];
            }
            
            [invocation invoke];
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

- (NSArray *)arrayByMappingBlock:(id (^)(id))block
{
    NSArray *mappedArray = @[];
    if (block) {
        NSMutableArray* anArray = [NSMutableArray arrayWithCapacity:self.count];
        
        for (id object in self) {
            id mappedObject = block(object);
            if (mappedObject) {
                [anArray addObject:mappedObject];
            }
        }
        mappedArray = [anArray copy];
    }
    return mappedArray;
}

@end
