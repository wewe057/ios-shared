//
//  SDDataMap.h
//
//  Created by brandon on 9/18/12.
//  Copyright (c) 2012 SetDirection. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Objects that support this protocol may be used to generate sub-objects, such as
 dictionaries and arrays being mapped into objects of specific types.
 */
@protocol SDDataMapProtocol <NSObject>
@optional
/**
 Provides a mapping dictionary based on the input data in the form of "srcKey":"destKey".
 Caller can optionally pass nil which should return a default map.
 */
- (NSDictionary *)mappingDictionaryForData:(id)data;
/**
 Allows the model to be validated against some known values.
 */
- (BOOL)validModel;
@end


/**
 SDDataMap provides a mechanism by which to assign keypaths from one object to another.
 A plist can be specified by name to provide definitions, optionally a dictionary can be used.
 A sample plist is available as a private gist at: https://gist.github.com/bsneed/f32db309d2ed70902702
 
 ### SDDataMap Property List Format Specification ###
 
 * Keys in the plist/dictionary are processed as being from the source or object to be mapped.
 * Types are always of String.
 * Values are the destination keyPaths on the object being mapped-to.
 
 ### Examples of possible values: ###
 
 * `browseIdentifier`: ie: myObject.browseIdentifier
 * `textLabel.text, name`: This would assign the value to myObject.textLabel.text as well as myObject.name
 * `@selector(testSelector:)`: This would call the selector specified.  This is useful is additional processing
     needs to take place before the assignment.  This could also be accomplished in the above examples by making
     a setter for a given property.

 */
@interface SDDataMap : NSObject

/**
 Loads `mapName`.plist as a dictionary to use as a map specification.
 */
+ (SDDataMap *)mapForName:(NSString *)mapName;
/**
 Loads a dictionary for use as a map specification.
 */
+ (SDDataMap *)mapForDictionary:(NSDictionary *)dictionary;

/**
 Returns an SDDataMap with an empty mapping dictionary.  It's assumed that
 the model will supply the map when mapObject* is called.
 */
+ (SDDataMap *)map;

/**
 Maps object1's keypaths to object2 based on the specification that SDDataMap was instantiated with.
 */
- (void)mapObject:(id)object1 toObject:(id)object2 strict:(BOOL)strict;
- (void)mapObject:(id)object1 toObject:(id)object2;
- (void)mapJSON:(id)object1 toObject:(id)object2;

@end

/**
 Helper extensions to allow for more base types to be supported by KVO in a map.
 */

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
