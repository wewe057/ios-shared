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

- (void)callSelector:(SEL)aSelector returnAddress:(void *)result argumentAddresses:(void *)arg1, ...
{
	va_list args;
	va_start(args, arg1);
    
	if([self respondsToSelector:aSelector])
	{
		NSMethodSignature *methodSig = [[self class] instanceMethodSignatureForSelector:aSelector];
		NSInvocation *invocation = [NSInvocation invocationWithMethodSignature: methodSig];
		[invocation setTarget:self];
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
		if (result)
			[invocation getReturnValue:result];
	}
    
	va_end(args);
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
