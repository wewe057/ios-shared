//
//  SDURLCacheWalmartExtensions.h
//  walmart
//
//  Created by Steven Riggins on 1/25/12.
//  Copyright (c) 2012 Walmart. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDURLCache.h"

@interface SDURLCache (SDURLCacheWalmartExtensions)

- (BOOL)isCachedAndValid:(NSURLRequest*)request;	// YES if url is in the cache and valid (ie non-expired)
- (NSCachedURLResponse*)validCachedResponseForRequest:(NSURLRequest *)request;	// Makes sure the response is not expired, otherwise nil

@end