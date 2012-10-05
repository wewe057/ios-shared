//
//  NSURLCache+SDExtensions.h
//  SetDirection
//
//  Created by Steven Riggins on 4/27/12.
//  Copyright (c) 2012 SetDirection. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLCache (SDExtensions)

- (BOOL)isCachedAndValid:(NSURLRequest*)request;	// YES if url is in the cache and valid (ie non-expired)
- (NSCachedURLResponse*)validCachedResponseForRequest:(NSURLRequest *)request;	// Makes sure the response is not expired, otherwise nil
- (NSCachedURLResponse*)validCachedResponseForRequest:(NSURLRequest *)request forTime:(NSTimeInterval)ttl;

// Ignore the expiration date. Just compare the ttl against the date in the header. Use with care.
- (NSCachedURLResponse*)suppopsedlyInvalidCachedResponseForRequest:(NSURLRequest *)request forTime:(NSTimeInterval)ttl;

@end