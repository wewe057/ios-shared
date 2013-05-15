//
//  NSObject+SDExtensions.m
//  billingworks
//
//  Created by brandon on 1/14/11.
//  Copyright 2011 Set Direction. All rights reserved.
//

#import "NSObject+SDExtensions.h"


@implementation NSObject (SDExtensions)

+ (NSString *)className
{
    return NSStringFromClass(self);
}

- (NSString *)className
{
    return [[self class] className];
}

+ (NSString *)nibName
{
    return [self className];
}

+ (id)loadFromNib
{
    return [self loadFromNibWithOwner:self];
}

+ (id)loadFromNibNamed:(NSString *)nibName
{
    return [self loadFromNibNamed:nibName withOwner:self];
}

+ (id)loadFromNibWithOwner:(id)owner
{
    return [self loadFromNibNamed:[self nibName] withOwner:self];
}

+ (id)loadFromNibNamed:(NSString *)nibName withOwner:(id)owner
{
    NSArray *objects = [[NSBundle bundleForClass:[self class]] loadNibNamed:nibName owner:owner options:nil];
	for (id object in objects)
    {
		if ([object isKindOfClass:self])
			return object;
	}
    
#if DEBUG
	NSAssert(NO, @"Could not find object of class %@ in nib %@", [self class], [self nibName]);
#endif
	return nil;
}

// This is tightly tied to the implementation found in NSObject+SDExtensions.m
// These is a reason that the implementation is duplicated and not called into NSObject's version.
// Please keep them duplicated otherwise the recursion bug that is being solved will happen again.

- (void)callSelector:(SEL)aSelector returnAddress:(void *)result argumentAddresses:(void *)arg1, ...
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
            if (result)
                [invocation getReturnValue:result];
        }
    }
}

- (void)performBlockInBackground:(NSObjectPerformBlock)performBlock completion:(NSObjectPerformBlock)completionBlock
{
    if (performBlock)
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            performBlock();
            if (completionBlock)
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionBlock();
                });
        });
}

- (void)__performBlockSelector:(NSObjectPerformBlock)block
{
    if (block)
        block();
}

- (void)performBlock:(NSObjectPerformBlock)performBlock afterDelay:(NSTimeInterval)delay
{
    /*dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if (performBlock)
            performBlock();
    });*/
    
    // ^^^ produces significant delay in just telling the block to execute.  when on the main queue, its less
    // performant to do this.
    
    if (performBlock)
        [self performSelector:@selector(__performBlockSelector:) withObject:[performBlock copy] afterDelay:delay];
}

@end
