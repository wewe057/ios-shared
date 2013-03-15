//
//  SDDataMap.h
//
//  Created by brandon on 9/18/12.
//  Copyright (c) 2012 SetDirection. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SDDataMap : NSObject

+ (SDDataMap *)mapForName:(NSString *)mapName;
+ (SDDataMap *)mapForDictionary:(NSDictionary *)dictionary;

- (void)mapObject:(id)object1 toObject:(id)object2 strict:(BOOL)strict;
- (void)mapObject:(id)object1 toObject:(id)object2;
- (void)mapJSON:(id)object1 toObject:(id)object2;

@end

// Helper extensions to allow for more base types to be supported by KVO in a map.

@interface NSString(SDDataMap)

- (NSNumber *)numberValue;
- (char)charValue;
- (short)shortValue;
- (NSDecimal)decimalValue;
- (long)longValue;
- (unsigned char)unsignedCharValue;
- (NSUInteger)unsignedIntegerValue;
- (unsigned int)unsignedIntValue;
- (unsigned long long)unsignedLongLongValue;
- (unsigned long)unsignedLongValue;
- (unsigned short)unsignedShortValue;

@end
