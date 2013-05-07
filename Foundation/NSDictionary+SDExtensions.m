//
//  NSDictionary+SDExtensions.m
//  walmart
//
//  Created by Brandon Sneed on 6/27/11.
//  Copyright 2011 Set Direction. All rights reserved.
//

#import "NSDictionary+SDExtensions.h"

@implementation NSDictionary (SDExtensions)

- (NSString *)stringForKey:(NSString *)key
{
    id obj = [self objectForKey:key];
    if ([obj isKindOfClass:[NSString class]])
        return obj;
    else
    if ([obj isKindOfClass:[NSNumber class]])
        return [obj stringValue];
    return nil;
}

- (NSInteger)intForKey:(NSString *)key { return [self integerForKey:key]; }
- (NSInteger)integerForKey:(NSString *)key
{
    id obj = [self objectForKey:key];
    if ([obj isKindOfClass:[NSString class]])
        return [obj integerValue];
    else
    if ([obj isKindOfClass:[NSNumber class]])
        return [obj integerValue];
    return 0;
}

- (NSUInteger)unsignedIntForKey:(NSString *)key { return [self unsignedIntegerForKey:key]; }
- (NSUInteger)unsignedIntegerForKey:(NSString *)key
{
    id obj = [self objectForKey:key];
    if ([obj isKindOfClass:[NSString class]])
    {
        NSNumber *number = [NSNumber numberWithInteger:[obj integerValue]];
        return [number unsignedIntegerValue];
    }
    else
    if ([obj isKindOfClass:[NSNumber class]])
        return [obj unsignedIntegerValue];
    return 0;
}

- (float)floatForKey:(NSString *)key
{
    id obj = [self objectForKey:key];
    if ([obj isKindOfClass:[NSString class]])
        return [obj floatValue];
    else
    if ([obj isKindOfClass:[NSNumber class]])
        return [obj floatValue];
    return 0;
}

- (double)doubleForKey:(NSString *)key
{
    id obj = [self objectForKey:key];
    if ([obj isKindOfClass:[NSString class]])
        return [obj doubleValue];
    else
    if ([obj isKindOfClass:[NSNumber class]])
        return [obj doubleValue];
    return 0;
}

- (long long)longLongForKey:(NSString *)key
{
    id obj = [self objectForKey:key];
    if ([obj isKindOfClass:[NSString class]])
        return [obj longLongValue];
    else
    if ([obj isKindOfClass:[NSNumber class]])
        return [obj longLongValue];
    return 0;
}

- (BOOL)boolForKey:(NSString *)key
{
    id obj = [self objectForKey:key];
    if ([obj isKindOfClass:[NSString class]])
        return [obj boolValue];
    else
    if ([obj isKindOfClass:[NSNumber class]])
        return [obj boolValue];
    return 0;
}

- (NSArray*)arrayForKey:(NSString *)key {
    id obj = [self objectForKey:key];
    if ([obj isKindOfClass:[NSArray class]])
        return obj;
    return nil;
}

- (BOOL)keyExists:(NSString *)key {
	return [self objectForKey:key] != nil;
}

// values for keypath

- (NSString *)stringForKeyPath:(NSString *)key
{
    id obj = [self valueForKeyPath:key];
    if ([obj isKindOfClass:[NSString class]])
        return obj;
    else
        if ([obj isKindOfClass:[NSNumber class]])
            return [obj stringValue];
    return nil;
}

- (NSInteger)intForKeyPath:(NSString *)keyPath { return [self integerForKeyPath:keyPath]; }
- (NSInteger)integerForKeyPath:(NSString *)keyPath
{
    id obj = [self valueForKeyPath:keyPath];
    if ([obj isKindOfClass:[NSString class]])
        return [obj integerValue];
    else
        if ([obj isKindOfClass:[NSNumber class]])
            return [obj integerValue];
    return 0;
}

- (NSUInteger)unsignedIntForKeyPath:(NSString *)keyPath { return [self unsignedIntegerForKeyPath:keyPath]; }
- (NSUInteger)unsignedIntegerForKeyPath:(NSString *)keyPath
{
    id obj = [self valueForKeyPath:keyPath];
    if ([obj isKindOfClass:[NSString class]])
    {
        NSNumber *number = [NSNumber numberWithInteger:[obj integerValue]];
        return [number unsignedIntegerValue];
    }
    else
        if ([obj isKindOfClass:[NSNumber class]])
            return [obj unsignedIntegerValue];
    return 0;
}

- (float)floatForKeyPath:(NSString *)keyPath
{
    id obj = [self valueForKeyPath:keyPath];
    if ([obj isKindOfClass:[NSString class]])
        return [obj floatValue];
    else
        if ([obj isKindOfClass:[NSNumber class]])
            return [obj floatValue];
    return 0;
}

- (double)doubleForKeyPath:(NSString *)keyPath
{
    id obj = [self valueForKeyPath:keyPath];
    if ([obj isKindOfClass:[NSString class]])
        return [obj doubleValue];
    else
        if ([obj isKindOfClass:[NSNumber class]])
            return [obj doubleValue];
    return 0;
}

- (long long)longLongForKeyPath:(NSString *)keyPath
{
    id obj = [self valueForKeyPath:keyPath];
    if ([obj isKindOfClass:[NSString class]])
        return [obj longLongValue];
    else
        if ([obj isKindOfClass:[NSNumber class]])
            return [obj longLongValue];
    return 0;
}

- (BOOL)boolForKeyPath:(NSString *)keyPath
{
    id obj = [self valueForKeyPath:keyPath];
    if ([obj isKindOfClass:[NSString class]])
        return [obj boolValue];
    else
        if ([obj isKindOfClass:[NSNumber class]])
            return [obj boolValue];
    return 0;
}

- (NSArray*)arrayForKeyPath:(NSString *)keyPath {
    id obj = [self valueForKeyPath:keyPath];
    if ([obj isKindOfClass:[NSArray class]])
        return obj;
    return nil;
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

- (NSString*)stringForKeyPath:(NSString*)keyPath defaultValue:(NSString*)defaultValue
{
	id	value = [self valueForKeyPath:keyPath defaultValue:defaultValue];
	
	// The value is expected to be a string, otherwise default
	if (![value isKindOfClass:[NSString class]])
		value = defaultValue;
	
	return value;
}



- (NSNumber*)numberForKeyPath:(NSString*)keyPath defaultValue:(NSNumber*)defaultValue
{
	id	value = [self valueForKeyPath:keyPath defaultValue:defaultValue];
	
	// The value is expected to be a number, otherwise default
	if (![value isKindOfClass:[NSNumber class]])
		value = defaultValue;
	
	return value;
}



- (NSArray*)arrayForKeyPath:(NSString*)keyPath defaultValue:(NSArray*)defaultValue
{
	id	value = [self valueForKeyPath:keyPath defaultValue:defaultValue];
	
	// The value is expected to be an array, otherwise default
	if (![value isKindOfClass:[NSArray class]])
		value = defaultValue;
	
	return value;
}



- (NSDictionary*)dictionaryForKeyPath:(NSString*)keyPath defaultValue:(NSDictionary*)defaultValue
{
	id	value = [self valueForKeyPath:keyPath defaultValue:defaultValue];
	
	// The value is expected to be a dictionary, otherwise default
	if (![value isKindOfClass:[NSDictionary class]])
		value = defaultValue;
	
	return value;
}

- (NSArray*)conformedArrayForKeyPath:(NSString*)keyPath defaultValue:(NSArray*)defaultValue
{
	id	value = [self valueForKeyPath:keyPath defaultValue:defaultValue];
	
	// Conform the value to an array if it is not an array
	if (![value isKindOfClass:[NSArray class]])
		value = value ? [NSArray arrayWithObject:value] : defaultValue;
	
	return value;
}



- (NSDictionary*)conformedDictionaryForKeyPath:(NSString*)keyPath defaultValue:(NSDictionary*)defaultValue
{
	id	value = [self valueForKeyPath:keyPath defaultValue:defaultValue];
	
	// Conform the value to a dictionary if it is not a dictionary
	if (![value isKindOfClass:[NSDictionary class]])
		value = value ? [NSDictionary dictionaryWithObject:value forKey:@"default"] : defaultValue;
	
	return value;
}


@end
