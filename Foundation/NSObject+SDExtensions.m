//
//  NSObject+SDExtensions.m
//  walmart
//
//  Created by Brandon Sneed on 9/12/11.
//  Copyright (c) 2011 Walmart. All rights reserved.
//

#import "NSObject+SDExtensions.h"

@implementation NSObject_SDExtensions

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
			[invocation setArgument:arg1 atIndex:2];
		void *theArg = nil;
		for (int i = 3; i < [methodSig numberOfArguments]; i++)
		{
			theArg = va_arg(args, void *);
			if (theArg)
				[invocation setArgument:theArg atIndex:i];
		}
		[invocation invoke];	
		if (result)
			[invocation getReturnValue:result];
	}
    
	va_end(args);
}

@end
