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

// This is tightly tied to the implementation found in NSArray+SDExtensions.m
// These is a reason that the implementation is duplicated and not called into NSObject's version.
// Please keep them duplicated otherwise the recursion bug that is being solved will happen again.

- (void)performSelector:(SEL)aSelector returnAddress:(void *)returnAddress argumentAddresses:(void *)arg1, ...
{
#define kMaximumCallSelectorArguments 20
    
    // if it doesn't respond to the selector we're about to send it, GTFO.
    if (![self respondsToSelector:aSelector])
        return;
    
    NSMethodSignature *methodSig = [[self class] instanceMethodSignatureForSelector:aSelector];
    NSUInteger numberOfArguments = [methodSig numberOfArguments] - 2;
    
    // it has more than 20 args???  Go smack the developer making methods w/ that many params.
    if (numberOfArguments >= kMaximumCallSelectorArguments)
        [NSException raise:@"SDException" format:@"performSelector:returnAddress:argumentAddresses: cannot take more than %i arguments.", kMaximumCallSelectorArguments];
    
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
    
    // call that mofo.
    NSObject *object = self;
    if([object respondsToSelector:aSelector])
    {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature: methodSig];
        [invocation setTarget:object];
        [invocation setSelector:aSelector];
        
        void *theArg = nil;
        for (NSUInteger i = 0; i < numberOfArguments; i++)
        {
            theArg = arguments[i];
            [invocation setArgument:theArg atIndex:i + 2];
        }
        
        [invocation invoke];
        
        [invocation getReturnValue:returnAddress];
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
