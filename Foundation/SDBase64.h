//
//  SDBase64.h
//  ios-shared
//
//  Created by Brandon Sneed on 5/29/13.
//  Copyright (c) 2013 SetDirection. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString(SDBase64)

/**
 Encodes a string to a base64 NSData.  Requires libresolv to be linked.
 */
- (NSData *)base64EncodedData;

/**
 Decodes a base64 string to NSData.  Requires libresolv to be linked.
 */
- (NSData *)base64DecodedData;

/**
 Decodes a base64 string to a new string.  Requires libresolv to be linked.
 */
- (NSString *)base64DecodedString;

/**
 Encodes a string to base64.  Requires libresolv to be linked.
 */
- (NSString *)base64EncodedString;

@end

@interface NSData(SDBase64)

/**
 Encodes an NSData object to a base64 NSData.  Requires libresolv to be linked.
 */
- (NSData *)base64EncodedData;

/**
 Decodes a base64 NSData to NSData.  Requires libresolv to be linked.
 */
- (NSData *)base64DecodedData;

/**
 Decodes a base64 NSData to a new string.  Requires libresolv to be linked.
 */
- (NSString *)base64DecodedString;

/**
 Encodes an NSData to base64 string.  Requires libresolv to be linked.
 */
- (NSString *)base64EncodedString;

@end
