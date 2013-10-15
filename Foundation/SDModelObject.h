//
//  SDModelObject.h
//  ios-shared
//
//  Created by Brandon Sneed on 10/15/13.
//  Copyright (c) 2013 SetDirection. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDDataMap.h"

/**
 *  SDModelObject is a base modeling class which ideally works in conjunction with SDDataMap.
 *  
 *  SDModelObject's mapFromObject will generate a new instance of this class/subclass and then
 *  make a call to mappingDictionaryForData in order to retrieve a map for use with SDDataMap
 *  and then map the sourceObject to the newly created instance.
 */
@interface SDModelObject : NSObject

/**
 *	Subclasses should override this method to provide a data map dictionary per the specifications
 *  for SDDataMap.  The map should be in the format of @{@"sourceKey": @"destKey"}.  The destination
 *  will always be the subclass of RxObject.
 *
 *	@return	A dictionary containing the data mapping dictionary.
 */
- (NSDictionary *)mappingDictionaryForData:(id)data;

/**
 *  The dictionary representation is an NSDictionary filled with the SDDataMap name values based on
 *  - mappingDictionaryForData:
 *
 *  @return A dictionary representing this object
 */
- (NSDictionary *)dictionaryRepresentation;

/**
 *  Utility creation method that maps a source object's name value pairs to the new object
 *
 *  @param sourceObject The source name / value pairs
 *
 *  @return A newly created and mapped object
 */
+ (instancetype)mapFromObject:(id)sourceObject;

@end
