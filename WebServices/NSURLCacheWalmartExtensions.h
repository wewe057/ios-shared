//
//  NSURLCacheWalmartExtensions.h
//  walmart
//
//  Created by Steven Riggins on 4/27/12.
//  Copyright (c) 2012 Walmart. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLCache (NSURLCacheWalmartExtensions)

- (BOOL)isCachedAndValid:(NSURLRequest*)request;	// YES if url is in the cache and valid (ie non-expired)
- (NSCachedURLResponse*)validCachedResponseForRequest:(NSURLRequest *)request;	// Makes sure the response is not expired, otherwise nil

@end