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

+ (id)loadFromNibWithOwner:(id)owner
{
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:[self nibName] owner:owner options:nil];
	for (id object in objects)
    {
		if ([object isKindOfClass:self])
			return object;
	}
    
	NSString *warning = [NSString stringWithFormat:@"Could not find object of class %@ in nib %@", [self class], [self nibName]];
	NSAssert(NO, warning);
	return nil;
}

@end
