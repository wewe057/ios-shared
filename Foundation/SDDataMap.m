//
//  SDDataMap.m
//
//  Created by brandon on 9/18/12.
//  Copyright (c) 2012 SetDirection. All rights reserved.
//

#import "SDDataMap.h"
#import "objc/runtime.h"

// used for typechecking.  expensive to create.
static NSNumberFormatter *__internalformatter = nil;

@implementation SDDataMap
{
    NSDictionary *_mapPlist;
    NSMutableDictionary *_typeCache;
}

+ (SDDataMap *)mapForName:(NSString *)mapName
{
	SDDataMap *result = nil;
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:mapName ofType:@"plist"];
    if (path)
    {
	    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:path];
	    result = [self mapForDictionary:dictionary];
    }
    
    return result;
}

+ (SDDataMap *)mapForDictionary:(NSDictionary *)dictionary
{
	SDDataMap *result = nil;

	result = [[SDDataMap alloc] init];
	result->_mapPlist = dictionary; // Do we need to use [NSDictionary dictionaryWithDictionary:dictionary] here?
	result->_typeCache = [[NSMutableDictionary alloc] init];
	if (!__internalformatter)
    {
        __internalformatter = [[NSNumberFormatter alloc] init];
        [__internalformatter setNumberStyle:NSNumberFormatterNoStyle];
    }
	return result;
}

+ (SDDataMap *)map
{
    return [SDDataMap mapForDictionary:nil];
}

static const char *getPropertyType(objc_property_t property)
{
    const char *attributes = property_getAttributes(property);
    char buffer[1 + strlen(attributes)];
    strlcpy(buffer, attributes, sizeof(buffer));
    char *state = buffer, *attribute;

    while ((attribute = strsep(&state, ",")) != NULL)
    {
        if (attribute[0] == 'T' && attribute[1] != '@')
        {
            // it's a C primitive type:
            /*
             if you want a list of what will be returned for these primitives, search online for
             "objective-c" "Property Attribute Description Examples"
             apple docs list plenty of examples of what you get for int "i", long "l", unsigned "I", struct, etc.
             */
            NSString *name = [[NSString alloc] initWithBytes:attribute + 1 length:strlen(attribute) - 1 encoding:NSASCIIStringEncoding];
            return (const char *)[name cStringUsingEncoding:NSASCIIStringEncoding];
        }
        else
        if (attribute[0] == 'T' && attribute[1] == '@' && strlen(attribute) == 2)
        {
            // it's an ObjC id type:
            return "id";
        }
        else
        if (attribute[0] == 'T' && attribute[1] == '@')
        {
            // it's another ObjC object type:
            NSString *name = [[NSString alloc] initWithBytes:attribute + 3 length:strlen(attribute) - 4 encoding:NSASCIIStringEncoding];
            return (const char *)[name cStringUsingEncoding:NSASCIIStringEncoding];
        }
    }

    return "";
}

- (NSDictionary *)propertiesForObject:(id)object
{
    if (!object)
        return nil;
    
    NSMutableDictionary *results = [[NSMutableDictionary alloc] init];
    
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([object class], &outCount);
    for (i = 0; i < outCount; i++)
    {
        objc_property_t property = properties[i];
        const char *propName = property_getName(property);
        if (propName)
        {
            const char *propType = getPropertyType(property);
            NSString *propertyName = [NSString stringWithUTF8String:propName];
            NSString *propertyType = [NSString stringWithUTF8String:propType];
            [results setObject:propertyType forKey:propertyName];
        }
    }
    free(properties);
    
    // returning a copy here to make sure the dictionary is immutable
    return [NSDictionary dictionaryWithDictionary:results];
}

- (id)convertValue:(id)value forType:(NSString *)type
{
    // All values are instances of NSString, NSNumber, NSArray, NSDictionary, or NSNull.

    // if we didn't do any conversion, send the same thing back out.
    id result = value;
    
    if (!value)
    {
        // handle non-obj types that need to be set to 0.
        if ([type length] == 1)
            result = [NSNumber numberWithInt:0]; // kvo will turn this into 0 for everything.
        else
            result = nil;
    }
    else
    if ([value isKindOfClass:[NSNull class]])
        result = nil;
    else
    if ([value isKindOfClass:[NSString class]])
    {
        if ([value isEqualToString:@"null"])
            result = nil;
        else
        // is this one necessary?
        if ([value isEqualToString:@"<nil>"])
            result = nil;
        else
        {
            if ([type isEqualToString:@"NSNumber"])
            {
                result = [__internalformatter numberFromString:value];
            }
        }
    }
    else
    if ([value isKindOfClass:[NSNumber class]])
    {
        if ([type isEqualToString:@"NSString"])
            value = [value stringValue];
    }
    
    // uncomment to see conversion info in the logs.
    if (result != value)
    {
        if (result == nil)
            SDLog(@"value %@ (%@) converted to <nil>", value, NSStringFromClass([value class]));
        else
            SDLog(@"value %@ (%@) converted to %@ (%@)", value, NSStringFromClass([value class]), result, NSStringFromClass([result class]));
    }
    
    return result;
}

- (void)setValue:(id)value forKeyPath:(NSString *)keyPath withTarget:(id)targetObject
{
    // find out who the owner of the property we're being asked to set.
    id targetParent = targetObject;
    NSRange range = [keyPath rangeOfString:@"." options:NSBackwardsSearch];
    NSString *parentPath = keyPath;
    NSString *propName = keyPath;
    // if its not found, that assumes targetObject is the bottom
    if (range.location != NSNotFound)
    {
        parentPath = [keyPath substringToIndex:range.location];
        propName = [keyPath substringFromIndex:range.location+1];
        targetParent = [targetObject valueForKeyPath:parentPath];
    }
    // load a cached version of the property data.
    NSDictionary *props = [_typeCache objectForKey:parentPath];
    if (!props)
    {
        // we didn't find anything in the cache, so create a new one and put it in the cache.
        props = [self propertiesForObject:targetParent];
        [_typeCache setObject:props forKey:parentPath];
    }
    
    //NSLog(@"props = %@", props);
    NSString *propType = [props objectForKey:propName];
    SDLog(@"%@ type is %@", propName, propType);
    
    // Try to do type conversions where possible to match the receiver.
    // Only do this on object types.  KVO handles scalar types on its own.

    value = [self convertValue:value forType:propType];
    [targetObject setValue:value forKeyPath:keyPath];
}

- (void)callSelector:(SEL)aSelector target:(id)target returnAddress:(void *)result argumentAddresses:(void *)arg1, ...
{
	va_list args;
	va_start(args, arg1);
    
	if([self respondsToSelector:aSelector])
	{
		NSMethodSignature *methodSig = [[target class] instanceMethodSignatureForSelector:aSelector];
		NSInvocation *invocation = [NSInvocation invocationWithMethodSignature: methodSig];
		[invocation setTarget:target];
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

- (BOOL)hasSelectorMarker:(NSString *)path
{
    NSRange selectorToken = [path rangeOfString:@"@selector("];
    return (selectorToken.location != NSNotFound);
}

- (void)performSelectorOnTarget:(id)targetObject forKeyPath:(NSString *)keyPath withValue:(id)value strict:(BOOL)strict
{    
    // keeps implementors from needing to worry about NSNull.
    if ([value isKindOfClass:[NSNull class]])
        value = nil;
    
    // separate the path from the selector if there is one
    NSRange range = [keyPath rangeOfString:@".@selector("];
    NSString *newPath = nil;
    NSMutableString *selectorString = nil;
    
    if (range.location != NSNotFound)
    {
        newPath = [keyPath substringWithRange:NSMakeRange(0, range.location)];
        selectorString = [[keyPath substringFromIndex:range.location + range.length] mutableCopy];
    }
    else
        selectorString = [keyPath mutableCopy];
    
    // get the object the selector should be performed on..
    id target = targetObject; // default if there's no keypath.
    if (newPath)
        target = [targetObject valueForKeyPath:newPath];
    
    // make sure the selector is formatted right and doesn't have junk in it.
    [selectorString replaceOccurrencesOfString:@"@selector(" withString:@"" options:0 range:NSMakeRange(0, selectorString.length)];
    [selectorString replaceOccurrencesOfString:@")" withString:@"" options:0 range:NSMakeRange(0, selectorString.length)];
    if ([selectorString rangeOfString:@":"].location == NSNotFound)
        [selectorString appendString:@":"];
    
    // call that selector..
    SEL selector = NSSelectorFromString(selectorString);
    if ([target respondsToSelector:selector])
    {
        NSMethodSignature *signature = [target methodSignatureForSelector:selector];
        const char *type = [signature getArgumentTypeAtIndex:2]; // 0 is self, 1 is SEL, 2 is the first parameter.
        SDLog(@"Selector type is %s", type);
        
        // attempt to convert value to an NSNumber to pass to the selector.
        NSNumber *tempValue = nil;
        if ([value isKindOfClass:[NSString class]])
            tempValue = [__internalformatter numberFromString:value];
        
        // type encodings: https://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html
        
        // you'll get a perfectly valid warning here, however we're a little more in the know
        // about what we're doing than clang/arc is.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        
        if (tempValue && !strict)
        {
            switch (type[0])
            {
                case 'c':
                {
                    char c = [tempValue charValue];
                    [self callSelector:selector target:target returnAddress:nil argumentAddresses:&c];
                    break;
                }
                    
                case 'i':
                {
                    int i = [tempValue intValue];
                    [self callSelector:selector target:target returnAddress:nil argumentAddresses:&i];
                    break;
                }
                    
                case 's':
                {
                    short s = [tempValue shortValue];
                    [self callSelector:selector target:target returnAddress:nil argumentAddresses:&s];
                    break;
                }
                    
                case 'l':
                {
                    long l = [tempValue longValue];
                    [self callSelector:selector target:target returnAddress:nil argumentAddresses:&l];
                    break;
                }
                    
                case 'q':
                {
                    long long q = [tempValue longLongValue];
                    [self callSelector:selector target:target returnAddress:nil argumentAddresses:&q];
                    break;
                }
                    
                case 'C':
                {
                    unsigned char C = [tempValue unsignedCharValue];
                    [self callSelector:selector target:target returnAddress:nil argumentAddresses:&C];
                    break;
                }
                    
                case 'I':
                {
                    unsigned int I = [tempValue unsignedIntValue];
                    [self callSelector:selector target:target returnAddress:nil argumentAddresses:&I];
                    break;
                }
                    
                case 'S':
                {
                    unsigned short S = [tempValue unsignedShortValue];
                    [self callSelector:selector target:target returnAddress:nil argumentAddresses:&S];
                    break;
                }
                    
                case 'L':
                {
                    unsigned long L = [tempValue unsignedLongValue];
                    [self callSelector:selector target:target returnAddress:nil argumentAddresses:&L];
                    break;
                }
                    
                case 'Q':
                {
                    unsigned long long Q = [tempValue unsignedLongLongValue];
                    [self callSelector:selector target:target returnAddress:nil argumentAddresses:&Q];
                    break;
                }
                    
                case 'f':
                {
                    float f = [tempValue floatValue];
                    [self callSelector:selector target:target returnAddress:nil argumentAddresses:&f];
                    break;
                }
                    
                case 'D':
                {
                    double D = [tempValue doubleValue];
                    [self callSelector:selector target:target returnAddress:nil argumentAddresses:&D];
                    break;
                }
                    
                case 'B':
                {
                    bool B = [tempValue boolValue];
                    [self callSelector:selector target:target returnAddress:nil argumentAddresses:&B];
                    break;
                }
                    
                // unhandled types
                case 'v': // void
                case '*': // c string
                case '@': // object
                case '#': // Class object
                case ':': // SEL (selector)
                default:
                    [target performSelector:selector withObject:tempValue];
                    break;
            }
        }
        else
        {
            [target performSelector:selector withObject:value];            
        }
#pragma clang diagnostic pop
    }
}

- (NSString *)subtypeForPath:(NSString *)path
{
    NSString *subtype = [path stringByReplacingOccurrencesOfString:@"<(.*)>(.*)" withString:@"$1" options:NSRegularExpressionSearch range:NSMakeRange(0, path.length)];
    if ([subtype isEqualToString:path])
        return nil;
    return subtype;
}

- (NSString *)propertyForPath:(NSString *)path
{
    NSString *property = [path stringByReplacingOccurrencesOfString:@"<(.*)>(.*)" withString:@"$2" options:NSRegularExpressionSearch range:NSMakeRange(0, path.length)];
    if ([property isEqualToString:path])
        return nil;
    return property;
}

- (void)mapObject:(id)object1 toObject:(id)object2 strict:(BOOL)strict
{
    if (!_mapPlist)
    {
        // typically the destination object will be a model and should supply the map
        if ([object2 respondsToSelector:@selector(mappingDictionary)])
            _mapPlist = [object2 mappingDictionary];
        else
        // if we didn't find a mappingDictionary on object2, check object1
        if ([object1 respondsToSelector:@selector(mappingDictionary)])
            _mapPlist = [object1 mappingDictionary];
    }

    [_mapPlist enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        id value = [object1 valueForKeyPath:key];
        
        // allow for multiple assignments, ie: name, textLabel.text
        NSMutableString *keysString = [obj mutableCopy];
        [keysString replaceOccurrencesOfString:@" " withString:@"" options:0 range:NSMakeRange(0, [obj length]-1)];
        NSArray *keyPaths = [keysString componentsSeparatedByString:@","];
        
        for (NSString *path in keyPaths)
        {
            NSString *subtypeName = [self subtypeForPath:path];
            NSString *propertyName = [self propertyForPath:path];

            // look for @ to denote a selector to be called.
            if ([self hasSelectorMarker:path])
                [self performSelectorOnTarget:object2 forKeyPath:path withValue:value strict:strict];
            else
            {
                if (!subtypeName)
                    [self setValue:value forKeyPath:path withTarget:object2];
                else
                {
                    /*
                     it's an array or dictionary, and the map says the sub items should be
                     of specific types.
                    */

                    if ([value isKindOfClass:[NSArray class]])
                    {
                        NSArray *array = value;
                        NSMutableArray *outputArray = [NSMutableArray array];
                        for (NSUInteger i = 0; i < array.count; i++)
                        {
                            Class specificClass = NSClassFromString(subtypeName);
                            id<SDDataMapProtocol> modelObject = [[specificClass alloc] init];

                            // if the model object doesn't support the protocol, we don't know how
                            // to map the objects, if it does, let's do it.
                            if ([modelObject respondsToSelector:@selector(mappingDictionary)])
                            {
                                SDDataMap *newMap = [SDDataMap map];

                                id item = [array objectAtIndex:i];
                                [newMap mapObject:item toObject:modelObject strict:strict];

                                // assume models are valid unless model explicitly says no.
                                BOOL validModel = YES;
                                if ([modelObject respondsToSelector:@selector(validModel)])
                                {
                                    validModel = [modelObject validModel];
                                }
                                if (validModel)
                                    [outputArray addObject:modelObject];
                            }
                        }

                        // if it's not empty, then set it.
                        if (outputArray.count > 0)
                            [object2 setValue:outputArray forKey:propertyName];
                    }
                    else
                    if ([value isKindOfClass:[NSDictionary class]])
                    {
                        Class specificClass = NSClassFromString(subtypeName);
                        id<SDDataMapProtocol> modelObject = [[specificClass alloc] init];
                        if ([modelObject respondsToSelector:@selector(mappingDictionary)])
                        {
                            SDDataMap *newMap = [SDDataMap map];
                            [newMap mapObject:value toObject:modelObject strict:strict];

                            // assume models are valid unless model explicitly says no.
                            BOOL validModel = YES;
                            if ([modelObject respondsToSelector:@selector(validModel)])
                            {
                                validModel = [modelObject validModel];
                            }
                            if (validModel)
                                [object2 setValue:modelObject forKey:propertyName];
                        }
                    }
                    else
                    {
                        // not sure how we'd get here, but try and do it the normal way then
                        // and hope for the best.
                        [self setValue:value forKeyPath:path withTarget:object2];
                    }
                }
            }
        }
    }];
}

- (void)mapObject:(id)object1 toObject:(id)object2
{
    [self mapObject:object1 toObject:object2 strict:YES];
}

- (void)mapJSON:(id)object1 toObject:(id)object2
{
    [self mapObject:object1 toObject:object2 strict:YES];
}

@end

// Helper extension code

@implementation NSString(SDDataMap)

/*
 
 NSString has these conversion methods already.

 - doubleValue;
 - floatValue;
 - intValue;
 - integerValue;
 - longLongValue;
 - boolValue;
 
 ... so we implement these to allow KVO to do type conversion on its own.
 
 - charValue;
 - shortValue;
 - decimalValue;
 - longValue;
 - unsignedCharValue;
 - unsignedIntegerValue;
 - unsignedIntValue;
 - unsignedLongLongValue;
 - unsignedLongValue;
 - unsignedShortValue;
 
 */

- (NSNumber *)numberValue
{
    if (!__internalformatter)
    {
        __internalformatter = [[NSNumberFormatter alloc] init];
        [__internalformatter setNumberStyle:NSNumberFormatterNoStyle];
    }
    
    return [__internalformatter numberFromString:self];
}

- (char)charValue
{
    // handle some outlying cases.
    if ([self length] == 0)
        return 0;
    
    // look for the normal strings used for bool values.
    
    NSString *temp = [self uppercaseString];
    if ([temp isEqualToString:@"TRUE"])
        return 1;
    else
    if ([temp isEqualToString:@"FALSE"])
        return 0;
    else
    if ([temp isEqualToString:@"YES"])
        return 1;
    else
    if ([temp isEqualToString:@"NO"])
        return 0;
    else
    if ([temp isEqualToString:@"0"])
        return 0;
    else
    if ([temp isEqualToString:@"1"])
        return 1;
    
    // default result should be false.
    return 0;
}

- (short)shortValue
{
    short result = [[self numberValue] shortValue];
    return result;
}

- (NSDecimal)decimalValue
{
    NSDecimal result = [[self numberValue] decimalValue];
    return result;
}

- (long)longValue
{
    long result = [[self numberValue] longValue];
    return result;
}

- (unsigned char)unsignedCharValue
{
    unsigned char result = [[self numberValue] unsignedCharValue];
    return result;
}

- (NSUInteger)unsignedIntegerValue
{
    NSUInteger result = [[self numberValue] unsignedIntegerValue];
    return result;
}

- (unsigned int)unsignedIntValue
{
    unsigned int result = [[self numberValue] unsignedIntValue];
    return result;
}

- (unsigned long long)unsignedLongLongValue
{
    unsigned long long result = [[self numberValue] unsignedLongLongValue];
    return result;
}

- (unsigned long)unsignedLongValue
{
    unsigned long result = [[self numberValue] unsignedLongValue];
    return result;
}

- (unsigned short)unsignedShortValue
{
    unsigned short result = [[self numberValue] unsignedShortValue];
    return result;
}


@end

